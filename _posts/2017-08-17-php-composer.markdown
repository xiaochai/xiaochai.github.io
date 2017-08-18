---
layout: post
title: "PHP Composer的基本使用"
date: 2017-08-17
categories:
  - Tech
description: 
image: http://image.phpcomposer.com/logo/phpcomposer.png
image-sm: http://image.phpcomposer.com/logo/phpcomposer.png
---

为了更加系统地了解Composer，完整地阅读了官方文档，并记录在此，供后续参考。

### Composer安装

- 参考[此链接](https://getcomposer.org/download/)

```shell
cd ~/bin
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

### 使用Composer

##### 创建测试项目

```shell
mkdir ~/work/composerTest/
cd ~/work/composerTest
```

##### 创建composer.json，内容如下

```json
{
    "require": {
        "monolog/monolog": "1.23.*"
    }
}
```

##### 使用Composer下载对应的依赖，生成自动加载文件(vendor/autoload.php)

```shell
composer.phar install -vvv
```

需要等一会，因为连接的国外的源，会比较慢

安装完成后，会发现多了vendor目录和composer.lock文件

##### 加载使用Monolog库

创建index.php，参考[Monolog库的官方文档](https://github.com/Seldaek/monolog)

```php
<?php

include_once "vendor/autoload.php";

use Monolog\Logger;
use Monolog\Handler\StreamHandler;

// create a log channel
$log = new Logger('name');
$log->pushHandler(new StreamHandler('./log.log', Logger::WARNING));

// add records to the log
$log->warning('Foo');
$log->error('Bar');
```

* 原则上不需要提交vendor目录下的内容到项目的版本管理

### composer.json配置文件

可以依赖此JSON Schema来校验composer.json文件(validate命令)

Root包：是指你当前所工作的包，一般来说是你的项目，这个是相对于依赖包来说的

##### require key

require包含包名称和包版本映射关系，而包名称又包含供应商名称和项目名称

如之前的composer.json，包名称monolog/monolog，此处的供应商名称和项目名称都为monolog，版本号为1.23.*

对于版本约束，如下：

- 使用确切的版本号，如1.23.1
- 使用范围，如>=1.0、>=1.0,<2.0、>=1.0,<1.1|>=1.2；其中逗号表示与，|表示或，与的优先级较高
- 使用通配符，如1.0.*，相当于>=1.0,<1.1
- 语义化版本(Semantic Versioning)，或者叫下一个重要版本，如~1.2表示>=1.2,<2.0、~1.2.3表示为>=1.2.3,<1.3

稳定性标签：以@开头，例如@dev表示空的版本约束，1.0.*@beta，表示允许依赖一个不稳定的包(beta版本)

明确版本引用：#<ref>，ref表示版本控制的提交编号，如git为md5，dev-master#2eb0c0978d290a1c45346a1955188929cb4e5db7

##### require-dev key

这个列表是为开发或测试等目的，额外列出的依赖。可以使用--no-dev跳过对require-dev依赖的安装

##### autoload key

可以composser.json里添加以下内容，来告诉Composer新的autoload规则

```json
{
    "autoload":{
        "psr-4":{
            "Ns1\\":"Ns1/"
        }
    }
}
```

*Ns1/Math.php*

```php
<?php
namespace Ns1;

class Math{
    public static function sum($a, $b){
        return $a+$b;
    }
}
```

```php
<?php
include_once "vendor/autoload.php";

use \Ns1\Math;
var_dump(Math::add(1,2));
```

这样autoload就会自动在与vendor同级目录下的Ns1里找到对应的\Ns1\Math类




##### name key

只有包含了一composer.json在你的项目中，那么它就是一个包。你的项目与包的区别仅仅是你的项目没有名字。

在composer.json里添加以下内容，可以为项目添加名字

```json
{
    "name":"xiaochai/composer-test"
}

```

虽然包名不区分大小写，但惯例是使用小写字母，并用连字符作为单词的分隔

##### description

一个包的简短描述。通常这个最长只有一行。对于需要发布的包（库），这是必须填写的。

##### version

不是必须的，并建议不填写，因为可以从版本库推导出版本号来

##### keyword,homepage,time,license,authors,support

分别表示项目的相关信息，

- keyword:项目的关键字，用户搜索和过滤
- homepage:项目的主页
- time:版本发布时间
- license:许可协议
- authors:作者信息，为一个数组对象，可以包含以下信息name,email,homepage,role
- support:获取项目支持的向相关信息对象，可以包含以下信息email,issues,forum,wiki,irc,source

##### type

包的安装类型，默认为library，这种类型会简单的把代码复制到vendor

不同的类型会对应不同的处理，除了内置类型，还可以自定义类型，这就要求项目能够识别此类型，并进行对应安装

##### repositories key

如果将之前的包提交到github，那么就可以使用respositories来指定源申明

```json
{
    "repositories":{
        "type":"vcs",
        "url":"https://github.com/xiaochai/composer-test"
    },
    "require":{
        "xiaochai/composer-test":"dev-master"
    }
}
```

Composer的默认源地址为https://packagist.org/




### composer.lock锁文件

在install完成之后，Composer会将当前安装的确切版本写入到composer.lock文件。如果再次install，Composer会先读取锁文件的内容，直接下载对应版本的依赖

composer.lock文件需要提交到项目的版本管理中，这样项目的其它参与者的开发环境，测试环境，以及持续集成服务器都使用相同版本的依赖，减少潜在的影响

如果想更新对应的版本，可以使用update命令更新全部包或者指定包，Composer将会依据composer.json获取最新版本，并更新到composer.lock文件中

```shell
composer.phar update
composer.phar update monolog/monolog [...]
```

### Composer命令行常用命令

##### init

composer init会一步引导创建composer.json文件

##### install

composer install 会读取当前目录下的composer.json文件，处理依赖关系，安装到vendor目录下

如果目录下存在composer.lock文件，则会从此文件读取依赖，如果没有composer.lock，Composer将在处理完之后创建

常用参数:

- --prefer-source，--prefer-dist：表示从版本控制源安装还是从分发版本安装
- --dev：安装require-dev字段列出来的依赖(默认)
- --no-dev：不安装require-dev字段列出来的依赖

##### update

升级composer.lock文件，获取最新版本的依赖，此命令将重写composer.lock文件


##### require

申明依赖，如果运行composer.phar require，将会以交互式引导引入相应的依赖

可以在命令后面添加确切的包名进行非交互式的依赖包引入 

```shell
composer.phar require vendor/package:2.*
```

此命令将更新对应的composer.json和composer.lock文件

##### search

从源中搜索依赖包 

```shell
php composer.phar search monolog
```


