---
layout: post
comments: true
title: "libcurl对域名含有多个ip时的超时重试策略"
date: 2018-09-11
categories:
  - Tech
description: 
image: /assets/images/curl-logo.svg
image-sm: /assets/images/curl-logo.svg
---

### 缘起

一夜报警。

某一个服务的组件panic了，赶紧起来重启了对应的组件，并让负责这个组件的同事统计一下业务上调用这个服务失败的统计，看看是否需要补数据。

同事给的反馈是没有发现有请求异常，业务这边不受影响！

这一点都不科学，我翻看了业务上的代码，并没有重试的逻辑，对应的DNS也没有做过调整。

难道DNS自动调整了？难道PHP自动进行了重试吗？

我用脚趾头想了一下，DNS不可能会自动调整，他连我开的端口都无法感知，怎么能够自动调整呢？

所以那就是PHP的curl库有重连的逻辑，或者是libcurl有重连的逻辑了！

为了验证这点，我搞了个域名重现对应的场景。


### 再现现场

找了个域名 example.huajiao.com，解析到的10.143.153.63，10.139.230.68这两个ip上，dig结果如下：

```bash
➜  ~ dig example.huajiao.com

; <<>> DiG 9.10.6 <<>> example.huajiao.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52647
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;example.huajiao.com.		IN	A

;; ANSWER SECTION:
example.huajiao.com.	90	IN	A	10.143.153.63
example.huajiao.com.	90	IN	A	10.139.230.68

;; Query time: 6 msec
;; SERVER: 10.16.0.222#53(10.16.0.222)
;; WHEN: Tue Sep 11 16:54:08 CST 2018
;; MSG SIZE  rcvd: 78
```

这两个主机上都开了nginx服务，并监听8080端口，所以写了一个PHP脚本来访问此服务:

```php
<?php
echo "begin:" . date("Y-m-d H:i:s\n");
$begin = microtime(true);
$url = "http://example.huajiao.com:8080";
$ch = curl_init ($url) ;
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1) ;
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT_MS, 500);
$res = curl_exec ($ch) ;
curl_close ($ch) ;
echo "res:" . $res . "\n";
echo "cost:" . (microtime(true)-$begin)."\n";
```

执行结果:

```bash
➜  ~ php get.php
begin:2018-09-11 17:12:25
res:ok
cost:0.0053741931915283
```

可以看出正常情况下大概耗时5ms左右。多次请求结果基本都是这样。

此时，将10.143.153.63这个机器上的nginx关闭。

多次执行get.php结果基本上得到如下两种结果，要么耗时在5ms左右，要么耗时在255ms左右，但一个失败都没有。

```bash
➜  ~ php get.php
begin:2018-09-11 17:20:29
res:ok
cost:0.25464820861816

➜  ~ php get.php
begin:2018-09-11 17:21:44
res:ok
cost:0.0078651905059814
```


而使用curl直接对10.143.153.63发起请求，则一直卡在connecting那块，直到超时：

```bash
➜  ~ curl 'http://10.143.153.63:8080' -H "Host:example.huajiao.com" -v
* About to connect() to 10.143.153.63 port 8080 (#0)
*   Trying 10.143.153.63...
* Connection timed out
* couldn't connect to host
* Closing connection #0
curl: (7) couldn't connect to host
```

### 分析

在这个现场下，我们开启了抓包的工具：

```bash
➜  ~ tcpdump -vvXnSs 0 'host 10.143.153.63 or host 10.139.230.68 ' -i eth0 -w example.cap
```

使用wireshark查看耗时较长的请求当时的发包情况：

![wireshark](https://wx3.sinaimg.cn/large/6a1f6674ly1fv5ql2azu3j21kw0gagyx.jpg)

可以看出，在往10.143.153.63发送sync包，并且在250ms没有返回的时候，又向另外一个ip 10.139.230.68发起了请求了，他进行了重试！

这个250ms刚好是我们设置的连接超时500ms的一半，这其中是一种怎么样的策略呢？

本着不搞清楚今天不工作的态度，从PHP的源码查到了libcurl的源代码，终于在libcurl里的lib/connect.c里找到对应的代码:

```c
/*
 * TCP connect to the given host with timeout, proxy or remote doesn't matter.
 * There might be more than one IP address to try out. Fill in the passed
 * pointer with the connected socket.
 */

CURLcode Curl_connecthost(struct connectdata *conn,  /* context */
                          const struct Curl_dns_entry *remotehost)
{
  struct Curl_easy *data = conn->data;
  struct curltime before = Curl_now();
  CURLcode result = CURLE_COULDNT_CONNECT;

  timediff_t timeout_ms = Curl_timeleft(data, &before, TRUE);

  if(timeout_ms < 0) {
    /* a precaution, no need to continue if time already is up */
    failf(data, "Connection time-out");
    return CURLE_OPERATION_TIMEDOUT;
  }

  conn->num_addr = Curl_num_addresses(remotehost->addr);
  conn->tempaddr[0] = remotehost->addr;
  conn->tempaddr[1] = NULL;
  conn->tempsock[0] = CURL_SOCKET_BAD;
  conn->tempsock[1] = CURL_SOCKET_BAD;

  /* Max time for the next connection attempt */
  conn->timeoutms_per_addr =
    conn->tempaddr[0]->ai_next == NULL ? timeout_ms : timeout_ms / 2;
```

由于对这个库和c代码不是特别了解，所以这块的代码还无法完全看懂，只明白在DNS返回多个ip的情况下，会对多个ip进行重试。

而在[这个邮件](https://curl.haxx.se/mail/lib-2014-11/0160.html#start)里作者对这个现象做了更进一步的描述，相应的回复邮件也提到了对应的机制。大意即会重试多个ip，每一个ip的超时时间都是之前的一半：

> The times allowed seem to be roughly the same ones as used in 7.36. It splits
> the maximum time for each IP tried. So 5 seconds for the first, 2.5 for the
> next and so on which gives the fifth IP a mere 312 milliseconds (adjusted
> somewhat since time is wasted every here and there so the last one actually
> only got 196 ms).

后续细读libcurl代码时再对整个策略做一个完整的解释。这里先记录下这个现象。

## 参考

[Changes to connection timeout policy when multiple DNS records are present](https://curl.haxx.se/mail/lib-2014-11/0160.html#start)

[curl_easy_perform - perform a file transfer synchronously](https://curl.haxx.se/libcurl/c/curl_easy_perform.html)

[PHP: curl_setopt](http://us1.php.net/manual/zh/function.curl-setopt.php)
