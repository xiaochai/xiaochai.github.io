---
layout: post
title: "那些与TIME_WAIT有关的参数"
date: 2019-03-16
categories:
  - Tech
description: 
image: "{{ site.baseurl }}/assets/images/sina/9866755ff640532fe997d969c4e5a4ea.jpg"
image-sm: "{{ site.baseurl }}/assets/images/sina/9866755ff640532fe997d969c4e5a4ea.jpg"
---

在机器上执行以下任意命令，就可以看到这个此机器上的TIME_WAIT的数量：

```shell
$ netstat -apn | grep TIME_WAIT | wc -l
39871
$ ss -ant  | grep TIME-WAIT | wc -l
32892
$ cat /proc/net/sockstat
sockets: used 1730
TCP: inuse 576 orphan 3 tw 32712 alloc 577 mem 226
UDP: inuse 5 mem 3
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 0 memory 0
```

关于TIME_WAIT的形成与其作用，我们在[这篇](/2017/11/14/tcp-ip/)文章中介绍过了。本文先介绍了几个相关的选项，并分别针对这些选项如何影响TIME_WAIT的数量做一些解释和对应的实验。

### net.ipv4.tcp_timestamps

在[这篇](/2017/11/14/tcp-ip/)文章中介绍了TCP协议头部的选项字段，其中有一个时间戳选项，这个选项与我们今天要聊的东西紧密相关，所以我们先从这个选项开始说起。

#### 开启时间戳选项

要开启tcp这个选项，需要将内核参数```net.ipv4.tcp_timestamps```设置成1(```sysctl -w net.ipv4.tcp_timestamps=1```)，可以通过以下两个命令来查看当前的内核参数设置:

```shell
$ sysctl net.ipv4.tcp_timestamps
net.ipv4.tcp_timestamps = 1
$ cat /proc/sys/net/ipv4/tcp_timestamps
1
```

#### 实现细节

假设A与B建立连接，在建立连接伊始A发送的SYN包中，就会带上时间戳字段TSval，B在回复SYN/ACK中会将A发来的TSval放在TSecr(echo reply)中，并同时带上新的时间戳字段TSval。整个过程如下图:

```
TCP  A                                                     TCP B

                        <[S],TSval=1,TSecr=0> ------>

             <---- <[S.],TSval=127,TSecr=1>

                        <[.],TSval=5,TSecr=127> ------>

             <---- <ACK(B),TSval=131,TSecr=5>

```

后续两端发送的所有包都会按照这个机制带上这两个时间戳字段。

#### 实际抓包

在使用tcpdump抓包中，可以很清晰地看到选项字段里带的TSval和TSecr：

![tsval]({{ site.baseurl }}/assets/images/sina/02f7297d7110758faaecba2fec74fa97.jpg)

而在没有开启时间戳选项(B没有开启)的交互中，A收到B的回包不带时间戳选项，后续再发的包，也就不再带时间戳选项了：

![notsval]({{ site.baseurl }}/assets/images/sina/257cc7f9eb4e181572da79f1960b7140.jpg)


#### 注意点

TSval并非真正的时间戳，而是由时间戳依据一定算法算出来的一个值，与时间戳有同等的特性，即随时间单调递增；

只有在TCP连接的客户端和服务器端都打开```net.ipv4.tcp_timestamps```，时间戳选项才会生效;

关于TSecr，一说只有在ACK标志的包中才会带，由于实际中基本没有不带ACK的包(除了第一个sync)，所以无法验证;

如果一个ACK包是回复之前收到的多个数据包，则此时的TSecr取值算法可参考[此](https://www.freesoft.org/CIE/RFC/1323/10.htm)，一般使用最早收到的那个TSval。

#### 作用

##### 精确计算RTT(Round-Trip Time)

在没有时间戳时计算RTT使用的方法是在包发送时记录下时间，RTT为收到ACK的时间减去发送时记录的时间。这种方法在出现丢失重传时，会导致RTT计算出现偏差，因为不确定ACK的回包是因为收到了最开始发的包，还是收到了重传后的包。

而时间戳选项可以很方便的使用TSecr来计算精准的RTT，当然，由于TSval并非真正的时间戳，所以计算时并非直接相减，而是使用相应的算法计算出RTT。

##### PAWS(Protection Against Wrapped Sequence numbers)

TCP的头部信息中序列号占用4个字节，即每传输4G的数据之后，序列号又要从头开始了(考虑到开始时随机选取的序列号，这个数字一般比4G小)。

考虑在一个高速网络中，某一个数据包A发生了超时重传，过了一段时间，此时序列号已经过了一轮又回到A了，之前丢失的包如果此时被收到就会被当成合法的包加以使用，这就是PAWS要解决的问题。

在添加了时间戳的选项的包中，PAWS在处理逻辑中添加了一条如下规则：如果收到的包的TSval小于最近一次收到的时间戳，则认为是不合法的，这就保证之前的包不会被当成合法的包。(这中间还有一些细节的处理，比如何时更新最近一次收到的时间戳，对于重传情况的处理等，可以参考具体的RFC文档)


### net.ipv4.tcp_tw_reuse

#### 现象

众所周知，可用的端口号有65535个，而实际能用的端口数还受```net.ipv4.ip_local_port_range```和```net.ipv4.ip_local_reserved_ports```影响。为了探究reuse选项对TIME_WAIT的影响，将可用端口改成10个，并关闭reuse选项:

```shell
$ sysctl -w net.ipv4.ip_local_port_range="34000 34009"
$ sysctl -w net.ipv4.tcp_tw_reuse=0
```

接下来连续发起请求

```shell
$ for ((i=0;i<1000;i++)); do curl http://192.168.1.111; done;
```
可以发现很快就会报错: ```curl: (7) Failed to connect to 192.168.1.111: Cannot assign requested address```

> 这个步骤有时能一直请求，需要抓包看一下主动断开的是哪一方，如果是服务端主动断开，则TIME_WAIT在服务端，所以你的请求会持续成功

接下来我们打开reuse再试一次：

```shell
$ sysctl -w net.ipv4.tcp_tw_reuse=1
```

这次出现了很奇怪的现象，发现成功发起了10次请求之后与之前一样开始报错，但是在大约过了1秒左右，又开始能成功请求10个，然后继续报错，如此往复。

这个现象与之前网上查阅到的 "如果开启reuse，那么TIME_WAIT将在1秒之后重用" 这个说法很吻合。先暂且不解释这个现象，接着我们的实验。

以上实验的基础是服务端和客户端都打开了tcp_timestamps这个选项，如果某一方关闭timestamps，reuse还能起作用吗？

从结果上看，如果关闭了timestamps选项，则reuse也不起作用了，与没有打开reuse现象一样，即在前10次成功请求之后的请求全都报错了。

#### 代码

tcp相关的内核代码错综复杂，目前还无法从头到尾梳理一遍，只能从现象上找到对应的代码来佐证，所以我们从这个报错入手。

```Cannot assign requested address```这个在内核代码中并没有找到对应的字符串，只是从众多的注释上看，可以知道```EADDRNOTAVAIL```这个错误码就代表了这个报错

另外一方面，搜索```tcp_tw_reuse```这个关键字，我们可以找到以下代码：

net/ipv4/tcp_ipv4.c

```c
int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
{
	const struct tcp_timewait_sock *tcptw = tcp_twsk(sktw);
	struct tcp_sock *tp = tcp_sk(sk);

	/* With PAWS, it is safe from the viewpoint
	   of data integrity. Even without PAWS it is safe provided sequence
	   spaces do not overlap i.e. at data rates <= 80Mbit/sec.

	   Actually, the idea is close to VJ's one, only timestamp cache is
	   held not per host, but per port pair and TW bucket is used as state
	   holder.

	   If TW bucket has been already destroyed we fall back to VJ's scheme
	   and use initial timestamp retrieved from peer table.
	 */
	if (tcptw->tw_ts_recent_stamp &&
	    (twp == NULL || (sysctl_tcp_tw_reuse &&
			     get_seconds() - tcptw->tw_ts_recent_stamp > 1))) {
		tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
		if (tp->write_seq == 0)
			tp->write_seq = 1;
		tp->rx_opt.ts_recent	   = tcptw->tw_ts_recent;
		tp->rx_opt.ts_recent_stamp = tcptw->tw_ts_recent_stamp;
		sock_hold(sktw);
		return 1;
	}

	return 0;
}
```

而此函数的调用处，在返回0时会返回```EADDRNOTAVAIL```错误码，所以这块可以猜到应该就是判断TIME_WAIT是否可以重用的代码


net/ipv4/inet_hashtables.c

```c
static int __inet_check_established(struct inet_timewait_death_row *death_row,
				    struct sock *sk, __u16 lport,
				    struct inet_timewait_sock **twp)
{
	// skip something
	/* Check TIME-WAIT sockets first. */
	sk_nulls_for_each(sk2, node, &head->twchain) {
		tw = inet_twsk(sk2);

		if (INET_TW_MATCH(sk2, net, hash, acookie,
					saddr, daddr, ports, dif)) {
			if (twsk_unique(sk, sk2, twp)) // 这个函数也就是上面看到的tcp_twsk_unique函数
				goto unique;
			else
				goto not_unique;
		}
	}
	// skip something
unique:
	// skip something
	return 0;

not_unique:
	spin_unlock(lock);
	return -EADDRNOTAVAIL;
}
```

回过头来，我们看一下```tcp_twsk_unique```返回1的条件：

**```tcptw->tw_ts_recent_stamp```**： 搜索这个变量的赋值情况，都是在saw_tstamp为真是才会赋值，猜想这个saw_tstamp即为是否打开了timestamps选项，所以这个```tcptw->tw_ts_recent_stamp```只有在打开timestamps才会有值；

**```twp == NULL || (sysctl_tcp_tw_reuse && get_seconds() - tcptw->tw_ts_recent_stamp > 1)```**，这个twp不考虑是什么，如果要让sysctl_tcp_tw_reuse选项发生作用，这个twp必须不为空，所以这个条件的意思就是如果开启了reuse选项，并且当前时间(get_seconds)是在tw_ts_recent_stamp这个时间一秒之后，则为真；这是否与之前我们看到的现象1秒之后所有请求成功了相关呢？

以上是从现象再搜索代码猜测的结果，细节上应该还有些出入，但大概的情况应该也是这样了。

#### 总结

对于```net.ipv4.tcp_tw_reuse```，其作用是在TIME_WAIT状态1秒之后即可重用端口，达到快速回收TIME_WAIT端口的作用，避免出现无端口可用的情况，但是reuse的生效条件是通信双方都开启了timestamps选项。


### net.ipv4.tcp_tw_recycle 

将```net.ipv4.tcp_tw_recycle```选项打开，此时发起10次请求:

```
$ sysctl -w net.ipv4.tcp_tw_recycle=1
$ for ((i=0;i<10;i++)); do curl   http://192.168.1.111; done;
```

使用netstat持续观察TIME_WAIT的数量，发现这些TIME_WAIT持续时间特别短，1秒都不到就全部消失了。而把recycle重新关闭再试一下请求，TIME_WAIT又回来了。

这说明如果开启了recycle选项，则TIME_WAIT的端口可以快速回收，他与reuse的不同在于reuse在netstat中还能看到TIME_WAIT，只是可以复用这些端口，而recycle是直接回收了，使用netstat已经看不到了。

我们试着关闭timestamps看看有啥影响：发现这些TIME_WAIT又回来了，所以也是在timestamps打开的情况下recycle才能生效！

#### 代码

同样，我们也从代码上佐证这些现象。

net/ipv4/tcp_minisocks.c

```c

/*
 * Move a socket to time-wait or dead fin-wait-2 state.
 */
void tcp_time_wait(struct sock *sk, int state, int timeo)
{
	struct inet_timewait_sock *tw = NULL;
	const struct inet_connection_sock *icsk = inet_csk(sk);
	const struct tcp_sock *tp = tcp_sk(sk);
	int recycle_ok = 0;

	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
		recycle_ok = icsk->icsk_af_ops->remember_stamp(sk);

	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
		tw = inet_twsk_alloc(sk, state);

	if (tw != NULL) {
		// skip something

		if (recycle_ok) {
			tw->tw_timeout = rto;
		} else {
			tw->tw_timeout = TCP_TIMEWAIT_LEN;
			if (state == TCP_TIME_WAIT)
				timeo = TCP_TIMEWAIT_LEN;
		}

		inet_twsk_schedule(tw, &tcp_death_row, timeo,
				   TCP_TIMEWAIT_LEN);
		inet_twsk_put(tw);
	} else {
		/* Sorry, if we're out of memory, just CLOSE this
		 * socket up.  We've got bigger problems than
		 * non-graceful socket closings.
		 */
		LIMIT_NETDEBUG(KERN_INFO "TCP: time wait bucket table overflow\n");
	}

	tcp_update_metrics(sk);
	tcp_done(sk);
}
```

留意recycle_ok变量，从条件上可以看出，如果开启了recycle选项，并且```tp->rx_opt.ts_recent_stamp```不为空，则recycle_ok为真，继而对应的TIME_WAIT超时时间为rto，否则为TCP_TIMEWAIT_LEN。

这里有三个问题：

**tp->rx_opt.ts_recent_stamp**这个变量的值是什么：从代码中搜索，这个值的赋值为之前我们看到的tw_ts_recent_stamp，即开启timestamps选项时收到的最近一个包的时间戳，只有开启了timestamps这个变量才有值

**rto**和**TCP_TIMEWAIT_LEN**是多少：TCP_TIMEWAIT_LEN很容易搜索到是60秒，而rto呢？rto为Retransmission TimeOut，即重传超时，他是一个动态计算的值，在网络较好的情况下这个值一般都小于1秒，具体的算法可以查看参考文章。

**tcp_v4_remember_stamp**何时返回真：这里有一个```inet_getpeer(inet->daddr, 1)```函数，如果取到了peer信息，则返回真，否则返回0。

上面的代码，我们还能看到另外一个内核选项的作用```net.ipv4.tcp_max_tw_buckets```，当TIME_WAIT超过max_tw_buckets数量时，就不会再转入TIME_WAIT状态，而是报一条overflow的报错，这个报错可以在系统的/var/log/message里看到。

#### 总结

对于```net.ipv4.tcp_tw_recycle```选项，其作用是在将TIME_WAIT的超时时间设置成rto，而非60秒，而rto一般情况下会小于1秒，所以recycle经常能够快速回收处理TIME_WAIT状态的端口。而timestamps同样必须打开recycle才能生效。另外一种不生效的情况是```inet_getpeer```函数无法获取到对应的信息时，recycle也不会生效。

### 其它一些说明

#### 如何测试TIME_WAIT的超时时间

使用curl的```--local-port```选项可以大概地看出TIME_WAIT的超时时间

```
$ for ((i=0;i< 1000;i++)); do date; curl --local-port 54539  http://192.168.1.111; sleep 1; done;
```

查看两次正常返回的时间差即为TIME_WAIT状态的超时时间，这个在linux上是宏定义的60秒，无法修改。

#### 开启timestamps选项的弊端

除了包增加了10字节，还有一个[安全性的问题](https://stackoverflow.com/questions/7880383/what-benefit-is-conferred-by-tcp-timestamp)，目前还不明白这个是如何实现的:

> The TCP Timestamp when enabled will allow you to guess the uptime of a target system (nmap v -O . Knowing how long a system has been up will enable you to determine whether security patches that require reboot has been applied or not.

#### 开启recycle对于NAT网络的影响

对于服务器来说，如果同时开启了recycle和timestamps选项，则会开启一种称之为per-host的PAWS机制。与PAWS机制一样，per-host的PAWS机制是针对同一来源的包，只接收时间戳大于最近一次收到时间戳的包。但对于NAT网络来说，服务器认为的同一个来源，在NAT网关后面可能是多台客户机，而这些机器无法保证在时间戳上的单调递增，从而导致了某些客户机连接失败的情况，这也是作为服务端不推荐打开recycle的原因。


### 总结

在任何情况下打开reuse就够了，recycle不管是做为服务端还是做为客户端都不建议打开，除非你知道这意味着什么。而对于无法控制的服务端并且没有开启timestamps选项，可以通过减少tw_buckets来降低端口不可用的情况，但这相当于去掉了TIME_WAIT机制，带来的副作用可想而知。



### 参考

[TCP timestamp](http://perthcharles.github.io/2015/08/27/timestamp-intro/)

[What benefit is conferred by tcp timestamps](https://stackoverflow.com/questions/7880383/what-benefit-is-conferred-by-tcp-timestamp)


[一个NAT问题引起的思考](http://perthcharles.github.io/2015/08/27/timestamp-NAT/)


[TCP/IP重传超时--RTO - SRTT (Smoothed Round Trip Time)](https://blog.csdn.net/ztguang/article/details/79339076)

[TIME_WAIT状态下对接收到的数据包如何处理](https://blog.csdn.net/justlinux2010/article/details/8725479)

[tcp 协议小结](https://luoguochun.cn/post/2016-09-23-tcp-fuck/)

[再叙TIME_WAIT](https://huoding.com/2013/12/31/316)

[linux源码lxr](https://lxr.missinglinkelectronics.com/linux)

[tcp_tw_recycle和tcp_timestamp的问题](http://hustcat.github.io/tcp_tw_recycle-and-tcp_timestamp/)

[Which Timestamp to Echo](https://www.freesoft.org/CIE/RFC/1323/10.htm)

[TCP中RTT的测量和RTO的计算](https://blog.csdn.net/zhangskd/article/details/7196707)
