---
layout: post
title: "苹果电脑上的软件使用技巧"
date: 2018-02-11
categories:
  - Tech
description: 
image: /assets/images/sina/05b380865d13dd97de4462cb92c0ecf4.jpg
image-sm: /assets/images/sina/d7a8c9264dd9aef2b2044b6d8b9d1c5e.jpg
---

* macOS版本：10.13.3 High Sierra

### VirtualBox的文件夹共享

1. 下载安装完VirtualBox(版本号5.2.6 r120293)

2. 使用另外下载好的ubuntu-17.10.1-server-amd64.iso安装Ubuntu17.10 (Guest OS)

3. 从Settings=>Shared Folders=>点击添加按钮=> 选择宿主机文件夹（如/Users/liqingshou/Work）=> 文件夹名称（随意，如Work）=> 勾起Auto-mount（自动挂载）和Make Permanent（永久创建）

#### 遇到问题

##### 设置完之后，无法在系统里找到对应的挂载文件

> 发现/mnt或者/media目录都是空的，/dev也找不到，查了才知道需要安装GuestAdditions

* <strong>下载Extendsion Pack: Oracle_VM_VirtualBox_Extension_Pack-5.2.6-120293.vbox-extpack，并双击安装</strong>

* <strong>启动Ubuntu</strong>

* <strong>在VirtualBox的菜单上找到Device=>Insert Guest Additions CD Image</strong>

如果出现 Unable to insert the virtual optical disk ...提示，如下图

![insertCDError](/assets/images/sina/02bc603db4533bd1c7eb4411c617a051.jpg)

可以使用以下方法解决：

> 先关闭虚拟机，在Storage下找到对应的光盘，解绑对应的内容，然后再新建一个新的空光盘<br/>
> 现在执行以上步骤应该可以顺利通过了

![removeAttach](/assets/images/sina/b9a7ee0251a93d5986bb27337d98f7ae.jpg)

* <strong>在Ubuntu系统里挂载CD</strong>

```shell
sudo mount /dev/cdrom /media/cdrom/
```

* <strong>运行Guest Additions，完成后重启</strong>

```shell
sudo ./VBoxLinuxAdditions.run
```

* <strong>挂载共享目录</strong>

执行以下命令，则整个目录就被挂载到work目录下

```shell
$ mkdir work
$ sudo mount -t vboxsf Work ./work
```

如果出现如下报错

```shell
mount: wrong fs type, bad option, bad superblock on /dev/sdb1, missing codepage or helper program, or other error
	   In some cases useful info is found in syslog - try dmesg | tail or so.
```

可以使用以下命令，使用扩展里的mount.vboxsf工具

```shell
sudo ln -sf  /opt/VBoxGuestAdditions-5.2.6/other/mount.vboxsf /sbin/mount.vboxsf
```

##### 权限问题

挂载上的目录权限都为755，所有者均是root，这对于日常开发很不方便

* <strong>关闭Guest, 将刚才目录映射选择的Auto-mount勾去掉，然后再启动</strong>

* <strong>执行以下命令</strong>

```shell
test@ubuntu:~$ umask && id
0002
uid=1000(test) gid=1000(test) groups=1000(test),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),114(lpadmin),115(sambashare)

test@ubuntu:~$ sudo mount.vboxsf -o umask=002,gid=1000,uid=1000 Work ./work
```
此时，你可以看到work目录的文件都归属于目前的登录用户了。

* <strong>将配置加入/etc/fstab，实现启动后自动执行</strong>

```shell
Work /home/test/work vboxsf umask=002,gid=1000,uid=1000
```

#### 参考

[Unable to Install Guest Additions CD Image on Virtual Box](https://askubuntu.com/questions/573596/unable-to-install-guest-additions-cd-image-on-virtual-box)<br/>

[virtualbox ticket](https://www.virtualbox.org/ticket/16670)<br/>

[Share folders from the host Mac OS to a guest Linux system in VirtualBox](https://stackoverflow.com/questions/23514244/share-folders-from-the-host-mac-os-to-a-guest-linux-system-in-virtualbox)<br/>

[fstab](https://askubuntu.com/questions/123025/what-is-the-correct-way-to-share-directories-in-mac-and-ubuntu-with-correct-perm)

[How do I install Guest Additions in a VirtualBox VM?](https://askubuntu.com/questions/22743/how-do-i-install-guest-additions-in-a-virtualbox-vm)


### Beyond Compare的无限试用

* <strong>下载Beyond Compare(4.2.4)，并安装</strong>

* <strong>在试用期快结束的时候，删除registry.dat文件</strong>

registry.dat位于家目录下```~/Library/Application Support/Beyond Compare/registry.dat```，记录了注册和试用相关的信息，只要删除此文件，试用周期重新计算，达到无限试用的目的

* <strong>替换Beyond Compare的启动文件，在启动时删除registry.dat</strong>

找到对应的启动文件，使用新的脚本文件替换之

```shell
cd Applications/Beyond\ Compare.app/Contents/MacOS/
mv BCompare BCompare.real
touch BCompare
chmod +x BCompare
```

在BCompare文件中加入以下内容

```shell
#!/bin/bash
rm "/Users/$(whoami)/Library/Application Support/Beyond Compare/registry.dat"
"`dirname "$0"`"/BCompare.real
```

#### 参考

[Beyond Compare for mac 无限试用方法](https://www.qiangblog.com/post/mac/beyond-compare-for-mac-wu-xian-shi-yong-fang-fa)


### nginx、php-fpm环境的配置


#### nginx

```shell
brew install nginx
```

配置文件的路径为/usr/local/etc/nginx/nginx.conf

日志文件的目录为/usr/local/var/log/nginx/error.log

常用命令

```shell
nginx
nginx -s stop
nginx -s reload
```

#### php

```shell
brew install homebrew/php/php-version
brew install homebrew/php/php71 --with-fpm
brew install homebrew/php/php71-xdebug
brew services restart homebrew/php/php71
```

配置xdebug

/usr/local/etc/php/7.1/conf.d/ext-xdebug.ini

```ini
[xdebug]
zend_extension="/usr/local/opt/php71-xdebug/xdebug.so"
xdebug.idekey="macgdbp"
xdebug.remote_enable=1
xdebug.profiler_enable=1
xdebug.remote_host="127.0.0.1"
xdebug.remote_port=9001
xdebug.remote_handler="dbgp"
```


#### 参考

[Mac下Nginx环境配置](https://www.jianshu.com/p/31c9d412585a)


### PHPStorm的配置

PHPStorm 2017.3.4

PHP(local) 7.1.7

PHP(remote) 7.1

#### 配置PHP环境

新建项目时，选择或创建解释器

![phpInterprete](/assets/images/sina/cd1af9f8406fde851414475965bf5101.jpg)

在已经有项目中选择解释器：Preferences=> Languages & Frameworks => PHP

![phpInterete2](/assets/images/sina/834cf4dfcf0003a669f304dcb99c2b35.jpg)

配置远程的解释器，注意使用远程PHP运行时，需要配置Deployment(Tools=>Deplyment)或者配置Path Mapping(如果配置了Deployment会自动补上Path Mapping)。远程执行的原理是ssh到对应的机器上执行，并把结果返回输出到终端

![remoteInterprete](/assets/images/sina/c74b462cb1f14cac05461c79219d1bf0.jpg)

#### 配置Composer

* <strong> 配置Composer可执行文件</strong>

如果本地没有composer，PHPStorm可以帮忙下载对应的composer可执行文件(下载到当前项目的要目录)，当然如果本地有，直接选择即可

Preferences => Languages & Frameworks => PHP => Composer

![composer](/assets/images/sina/c5a36d60a5e7270a197dce55a953e8f2.jpg)

* <strong>初始化Composer: Tools => Composer => Init Composer</strong>

在生成的composer.json文件中写入对应的项目信息

* <strong>使用Composer安装依赖</strong>

![composer-install](/assets/images/sina/74549542dafdd553b5bd0d8f4c5e5c16.jpg)

安装完成后会自动补到composer.json文件中

也可以自己往composer.json里补充内容，然后在composer.json上右键=>Composer=>Update

```json
{
    "repositories":[
      {
        "type":"vcs",
        "url":"https://github.com/xiaochai/phplib"
      }
    ],
    "require":{
        "xiaochai/phplib":"dev-master"
    }
}
```

#### 配置PHPUnit

* <strong>配置PHPUnit可执行文件</strong>

Preferences => Languages & Frameworks => PHP => Test Frameworks => 选择添加 => PHPUnit Local

![phpunit](/assets/images/sina/0615b5eb9616a7db5442fb999d7eeca7.jpg)

注意：如果是远程的PHP解释器，那么PHPUnit也应该是远程的

* <strong>运行测试用例</strong>

在此之前，需要在Preferences => Languages & Frameworks => PHP => Include Path里添加phpunit.phar路径，这样IDE中关于PHPUnit的命名空间使用就不会报错

接着，在tests目录下创建测试文件，不管在文件上，或者在文件里的类名、函数名上点击，都可以出现运行测试用例的菜单，只是执行的用例范围不同

![testcase](/assets/images/sina/7ee215d277a4d262cdf25f95562f4c1d.jpg)

#### 运行配置

配置一个PHP Web Server，Run => Edit Configurations

![webserver](/assets/images/sina/2ea8daf2b58a5cbc78ac6b3d04267b8a.jpg)

设置调试端口，与xdebug配置的端口一致：Preferences=>Languages & Frameworks => PHP => Debug => Xdebug下的Debug port

选择刚新建的PHP Web Server(localhost)，选择调试，如果有打断点的话，就会在对应的断点停住了

![debug](/assets/images/sina/6691e7253f58dafa83fcf9374b12336f.jpg)

#### 参考

[http://idea.lanyus.com/](http://idea.lanyus.com/)

[http://blog.lanyus.com/archives/174.html](http://blog.lanyus.com/archives/174.html)

[http://www.imsxm.com/2018/02/jetbrain-education-license.html](http://www.imsxm.com/2018/02/jetbrain-education-license.html)

[https://juejin.im/post/5a684c575188257341081948](https://juejin.im/post/5a684c575188257341081948)
