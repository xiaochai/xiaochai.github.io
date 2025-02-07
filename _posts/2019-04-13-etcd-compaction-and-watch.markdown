---
layout: post
title: "由etcd自动压缩引发的诡异问题"
date: 2019-04-13
categories:
  - Tech
description: 
image: "{{ site.baseurl }}/assets/images/sina/76e06f9d99be00dd644156d641b0b065.jpg"
image-sm: "{{ site.baseurl }}/assets/images/sina/76e06f9d99be00dd644156d641b0b065.jpg"
---

etcd作为优秀的分布式key-value存储系统，被广泛应用于服务发现、配置管理等需要提供稳定可靠的分布式服务的场景中。

但在面对频繁更新操作的场景时，比如对于任务调度系统，每一个任务的分配、完成都会写入一次etcd，这导致了etcd的版本号迅速增加。

由于默认情况下，etcd会保存所有版本的副本，所以随着时间的增加，etcd的内存就会不断地上涨，直到超过2G（默认最大内存是2G）后无法写入。

对我们的使用场景来说，历史版本并不是十分重要，所以为了解决这个问题，我们添加了自动压缩的机制，在启动时添加```--auto-compaction-retention=24```参数，即可每天压缩前一天之前的所有版本号了，这样对应的内存也会释放不少。

看似完美解决了内存的问题，但引发了另外一个问题，发现在开启压缩之后，对应的服务时不时地就会报错，并且panic掉

报错内容如下：

```
panic: Campaign failed: etcdserver: mvcc: required revision has been compacted
```

示例代码如下:

```go
package main

import (
	"github.com/coreos/etcd/clientv3"
	"github.com/coreos/etcd/clientv3/concurrency"
	"github.com/prometheus/common/log"
	"golang.org/x/net/context"
)

func main(){
	cli, err := clientv3.New(clientv3.Config{Endpoints: []string{"127.0.0.1:2379"}})
	if err != nil {
		log.Fatal(err)
	}
	defer cli.Close()
	s1, err := concurrency.NewSession(cli)
	if err != nil {
		log.Fatal(err)
	}
	defer s1.Close()
	e1 := concurrency.NewElection(s1, "/my-election")
	if err := e1.Campaign(context.Background(), "e1"); err != nil {
		panic("Campaign error: " + err.Error())
	}
	// do something leader do
}
```

从报错上，可以理解为Compaign操作所需要的版本号已经被压缩了，但为啥这个Compaign会用到压缩前的版本号呢？我们来跟一下使用etcd作选举的过程。


#### etcd sdk中Compaign方法的工作机制

etcd的sdk中提供了多个不同实例竞争选主的api，关键的方法即Campaign方法。

同一时间多个实例同时调用Compaign方法，只会有一个实例返回成功成为leader，其它的实例都会阻塞等待之前的leader异常断开或者主动放弃(Resign)后进行新一轮的竞选。

深入其代码，发现实现这一功能的原理很简单，只是用了etcd服务提供的几个常用接口完成，见如下分析。


#### 源码分析

首先，会在指定的/my-election下创建以当前session对应的LeaseID为名的子目录设置为val值(即Campaign的第二个参数值)。使用watch命令，可以看到这一步的操作

```shell
➜  ~ etcdctl watch / --prefix
PUT
/my-election//694d6a14c23d6708
e1
```

在源码中，使用了一个事务来处理，主要是为了处理这个key已经存在的情况:

```go
	s := e.session
	client := e.session.Client()

	k := fmt.Sprintf("%s%x", e.keyPrefix, s.Lease()) // 子key的命名规则prefix+LeaseID
	// 以下事务判断k是否存在（通过判断创建版本是否为0），如果不存在，设置k为val，否则获取k的值
	txn := client.Txn(ctx).If(v3.Compare(v3.CreateRevision(k), "=", 0))
	txn = txn.Then(v3.OpPut(k, val, v3.WithLease(s.Lease())))
	txn = txn.Else(v3.OpGet(k))
	resp, err := txn.Commit()
	if err != nil {
		return err
	}
	e.leaderKey, e.leaderRev, e.leaderSession = k, resp.Header.Revision, s
	//resp.Succeeded在事务if为真的时候返回true，为假时返回false，所以以下逻辑是处理这个key已经存在的情况
	if !resp.Succeeded {
		kv := resp.Responses[0].GetResponseRange().Kvs[0]
		e.leaderRev = kv.CreateRevision
		if string(kv.Value) != val {
			// 如果值存在，并且原来值和现在提供的不为同一个值时，进行一些处理，这里不细究
			if err = e.Proclaim(ctx, val); err != nil {
				e.Resign(ctx)
				return err
			}
		}
	}

	// 关键函数，后面细分析
	_, err = waitDeletes(ctx, client, e.keyPrefix, e.leaderRev-1)
	if err != nil {
		// clean up in case of context cancel
		select {
		case <-ctx.Done():
			e.Resign(client.Ctx())
		default:
			e.leaderSession = nil
		}
		return err
	}
	e.hdr = resp.Header

	// 返回nil表示竞选成功
	return nil

```

留意以上代码中e.leaderRev这个值，发现这个值为当前session所对应的key的创建版本号（etcd提供了多种的版本号，当前版本号、创建版本号、最后一次修改版本号等）。

接下来进入引起阻塞的函数waitDeletes，从名字上看，是等待删除的意思，等待删除什么呢，我们往下看：

```go
// waitDeletes efficiently waits until all keys matching the prefix and no greater
// than the create revision.
func waitDeletes(ctx context.Context, client *v3.Client, pfx string, maxCreateRev int64) (*pb.ResponseHeader, error) {
	getOpts := append(v3.WithLastCreate(), v3.WithMaxCreateRev(maxCreateRev))
	for {

		resp, err := client.Get(ctx, pfx, getOpts...)
		if err != nil {
			return nil, err
		}
		if len(resp.Kvs) == 0 {
			return resp.Header, nil
		}
		lastKey := string(resp.Kvs[0].Key)
		if err = waitDelete(ctx, client, lastKey, resp.Header.Revision); err != nil {
			return nil, err
		}
	}
}
```

在无限for循环中首先调用了client.Get，获取的是我们设置的/my-election这个key下的值。

注意带的options:

> WithLastCreate：表示查找指定key为前缀```WithPrefix```的所有key，并以CreateVersion倒序排列```WithSort(SortByCreateRevision, SortDescend)```，只取第一个```WithLimit(1)```

> WithMaxCreateRev(maxCreateRev)：先看看这个maxCreateRev，这个是之前我们说的当前session对应key的创建版本号减1，而整个表示的就是添加最大版本号为maxCreateRev这样一个限定条件

整体连在一起就是获取在此session之前创建的最后一个key，只要这个key删除了，那么就有可能轮到自己竞选成功了，所以看接下来的代码：

如果返回值为空，即在此之前没有key了，那么竞选成功，直接返回；

如果此之前有key，那么调用waitDelete，等待这个key被删除之后再走这个循环，看看此之前还有没有key。

这里的waitDelete函数最重要的就是一个watch操作，代码如下：

```go
// 这里的key即之前获取到的本session之前的最后一个key, rev是Get操作之后的当前版本号，表示watch从这个版本号开始监听事件
func waitDelete(ctx context.Context, client *v3.Client, key string, rev int64) error {
	cctx, cancel := context.WithCancel(ctx)
	defer cancel()

	var wr v3.WatchResponse
	wch := client.Watch(cctx, key, v3.WithRev(rev))
	for wr = range wch {
		for _, ev := range wr.Events {
			// 如果监听到了删除事件，就返回，重新走一遍流程
			if ev.Type == mvccpb.DELETE {
				return nil
			}
		}
	}
	if err := wr.Err(); err != nil {
		return err
	}
	if err := ctx.Err(); err != nil {
		return err
	}
	return fmt.Errorf("lost watcher waiting for delete")
}
```

#### 总结

至此，我们已经看到了Compaign的核心流程，我们举一个由三个进程组成的系统，来展示一下这个逻辑的具体流程。

假设有三个进程p1、p2、p3，对应的leaseID分别是l1、l2、l3，prefix为/my-election

三个进程分别调用Compaign，对应的创建版本假设p1为1，p2为2，p3为3

按照这个逻辑，此时p1获取他之前的创建的key，因为1是第一个key，所以他获取到的为空，直接竞选成功了

而p2获取他之前创建 的key，得到l1，所以他需要监听l1的事件，直到这个key删除了，类似p3需要watch l2的删除事件

如果此时p2进程退出，对应的l2也会被删除（因为租约的关系），则此时p3就从waitDelete的watch中返回，但在Get他之前的key时，发现l1还在，所以继续监听l1的删除事件。

以上我们可以发现这个竞选机制，其实是一个先来后到的原则，只有在自己前面没有人了，自己才能竞选成功。


### 问题分析

回到开头提到的问题，我们再来审视一下这个报错```etcdserver: mvcc: required revision has been compacted```，结合之前了解的代码，可疑的地方有两个：


#### client.Get

在无限for循环里的client.Get，他所带的maxCreateRev参数，从调用开始都没有更新过，很可能是已经被压缩过的版本，这样会不会引发问题呢？我们做一下实验：

首先多次对同一个key多次执行put操作，提升版本号，然后使用compact命令压缩版本，再使用压缩之前的版本号请求GET

```shell
➜  ~ etcdctl put /testkey abc
OK
➜  ~ etcdctl put /testkey abc
OK
➜  ~ etcdctl put /testkey abc
OK
➜  ~ etcdctl get /testkey -w json
{"header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"revision":306,"raft_term":15},"kvs":[{"key":"L3Rlc3RrZXk=","create_revision":292,"mod_revision":306,"version":15,"value":"YWJj"}],"count":1}
➜  ~ etcdctl compaction 305
compacted revision 305
➜  ~ etcdctl get /testkey --rev 304 -w json
Error: etcdserver: mvcc: required revision has been compacted
```

虽然我们使用--rev 304请求get报错了，但在go程序中使用的WithMaxCreateRev(304)并没有报错，而是返回了正常的结果

```go
func main(){
	cli, err := clientv3.New(clientv3.Config{Endpoints: []string{"127.0.0.1:2379"}})
	if err != nil {
		log.Fatal(err)
	}
	defer cli.Close()

	getOpts := append(clientv3.WithLastCreate(), clientv3.WithMaxCreateRev(304))
	resp, err := cli.Get(context.TODO(), "/testkey", getOpts...)
	fmt.Println(resp);
	// 输出&{cluster_id:14841639068965178418 member_id:10276657743932975437 revision:306 raft_term:15  [key:"/testkey" create_revision:292 mod_revision:306 version:15 value:"abc" ] false 1}
}
```

所以，并不是这块报的错，那就只剩下另外一种可能了


#### watch

在waitDelete里有一个watch调用，这个watch如果版本很低的话会不会报错了呢？

使用命令行可发现，如果传一个compact过的版本号，确实会报错

```
➜  ~ etcdctl watch  /testkey --rev 304  -w json
watch was canceled (etcdserver: mvcc: required revision has been compacted)
{"Header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"raft_term":15},"Events":[],"CompactRevision":305,"Canceled":true,"Created":false}
Error: watch is canceled by the server
```

但是，这个watch使用的版本号是从Get请求里的返回的版本，我们设置的压缩时间是1个小时，这个版本号无论如何都不可能为压缩的版本号的。


而且通过测试，在watch过程中执行压缩操作，也不会影响watch。

那很奇怪了，这个watch是如何报错的呢？

#### 深入了解watch的机制

watch的流程略有复杂，我们挑选重要的来分析一下导致watch报错的原因。

我们来看一下最重要的一个结构体watchGrpcStream的run方法，位于clientv3/watch.go中

```go
// run is the root of the goroutines for managing a watcher client
func (w *watchGrpcStream) run() {
	var wc pb.Watch_WatchClient
	var closeErr error

	// substreams marked to close but goroutine still running; needed for
	// avoiding double-closing recvc on grpc stream teardown
	closing := make(map[*watcherStream]struct{})

	defer func() {
		// ... 清理工作
	}()

	// start a stream with the etcd grpc server
	if wc, closeErr = w.newWatchClient(); closeErr != nil {
		return
	}

	cancelSet := make(map[int64]struct{})

	var cur *pb.WatchResponse
	// 主要是以下for循环
	for {
		select {
		// Watch() requested
		case req := <-w.reqc:
			// ...处理新的watch请求
		// new events from the watch client
		case pbresp := <-w.respc:
			// ...处理watch到的事件
		// watch client failed on Recv; spawn another if possible
		case err := <-w.errc:
			// 在出现错误时，重试
			if isHaltErr(w.ctx, err) || toErr(w.ctx, err) == v3rpc.ErrNoLeader {
				closeErr = err
				return
			}
			if wc, closeErr = w.newWatchClient(); closeErr != nil {
				return
			}
			if ws := w.nextResume(); ws != nil {
				wc.Send(ws.initReq.toPB())
			}
			cancelSet = make(map[int64]struct{})

		case <-w.ctx.Done():
			return
		case ws := <-w.closingc:
			// skip something
		}
	}
}
```

在监听的几个channel下，留意w.errc这个错误。从注释里看，在rpc出现任何错误时，都会返回这个错，例如网络错误。

对，网络错误，这是一个常发生的错误，在发生这个错误之后，会新起一个WatchClient，并重新发送请求。那么问题来了，这个请求里带的rev是什么呢？如果还是原来的rev，那么很可能就会导致我们出现的报错。

发送请求是```wc.Send(ws.initReq.toPB())```，这个ws是从```w.nextResume()```来的，但从这个函数里看，还需要了解resuming的机制，我们只要了解他下一次发送的rev传的是多少即可，从ws.initReq.toPB()里可以看出真正的版本号是ws.initReq.rev字段。

在文件中搜索initReq.rev的赋值

```go
		case wr, ok := <-ws.recvc:
			// skip something

			if len(wr.Events) > 0 {
				nextRev = wr.Events[len(wr.Events)-1].Kv.ModRevision + 1
			}
			ws.initReq.rev = nextRev

```

而在run 函数里收到新事件的时候，会通过dispatchEvent和broadcastResponse方法，会往ws.recvc里写入新事件，最后把这个事件里的最新的版本号传到新的rev里，在重试的时候使用。

至此，我们可以大概了解了出现报错的原因：watch由于网络异常等原因出现重试，而重试使用的版本号为之前收到的最近一次事件返回的版本号，如果很久没有收到事件了，这个版本号就一直不更新，导致在重试时使用了压缩过的版本号。

#### 复现

我们使用一个简单的现象来复现一下这个现象

首先，开一个终端watch某一个key（终端1）

```
➜  ~ etcdctl watch  /testkey --rev 315  -w json
```

另外开一个终端（终端2），对另外一个key进行疯狂的put操作，然后进行compact操作

```
➜  ~ etcdctl put /a abc
OK
➜  ~ etcdctl put /a abc
OK
➜  ~ etcdctl put /a abc
OK
➜  ~ etcdctl put /a abc
OK
➜  ~ etcdctl get /a -w json
{"header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"revision":317,"raft_term":15},"kvs":[{"key":"L2E=","create_revision":2,"mod_revision":317,"version":73,"value":"YWJj"}],"count":1}
➜  ~ etcdctl compaction 317
compacted revision 317
```

此时终端1还没有任何反应。

为了模拟网络出问题的情况 ，我们直接将etcd服务停掉，然后再起起来，此时watch肯定进行了重试。

果然终端1就出现了如下的报错

```
watch was canceled (etcdserver: mvcc: required revision has been compacted)
{"Header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"raft_term":16},"Events":[],"CompactRevision":317,"Canceled":true,"Created":false}
Error: watch is canceled by the server
```

#### 解决

解决的办法也很简单，直接重试Campaign就可以了，因为Campaign本身也处理了key已经存在的情况。但需要注意在彻底出现网络问题的情况下不要出现死循环，这也是一个值得讨论的问题，etcd官方的[issue](https://github.com/coreos/etcd/issues/8980)中也提到这一些。

```go
	for {
		if err := e1.Campaign(context.Background(), "e1"); err != nil {
			// some strategies
			log.Warn("Campaign error: " + err.Error())
		}else{
			break;
		}
	}
```

### 参考

[Etcd Client Architecture](https://etcd.readthedocs.io/en/latest/)

[GoDoc](https://godoc.org/go.etcd.io/etcd/clientv3)

[etcdctl](https://github.com/etcd-io/etcd/tree/master/etcdctl)


