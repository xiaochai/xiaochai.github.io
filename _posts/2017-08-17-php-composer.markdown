---
layout: post
title: "PHP Composer的基本使用"
date: 2017-08-17
categories:
  - Tech
description: 
image: /assets/images/sina/b21a93b9fbd0dd636b247d2f0ebe11e9.jpg"
image-sm: /assets/images/sina/b21a93b9fbd0dd636b247d2f0ebe11e9.jpg"
---

为了更加系统地了解Composer，完整地阅读了官方文档，并记录在此，供后续参考。

Composer是一个php的包依赖管理工具，类似于nodejs的npm和ruby的bundler。

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

可以依赖[此JSON Schema](https://github.com/composer/composer/blob/master/res/composer-schema.json)来校验composer.json文件(validate命令)

Root包：是指你当前所工作的包，一般来说是你的项目，这个是相对于依赖包来说的

以下为支持的配置属性

##### require

require包含包名称和包版本映射关系，而包名称又包含供应商名称和项目名称

如之前的composer.json，包名称monolog/monolog，此处的供应商名称和项目名称都为monolog，版本号为1.23.*

对于版本约束，如下：

- 使用确切的版本号，如1.23.1
- 使用范围，如>=1.0、>=1.0,<2.0、>=1.0,<1.1\|>=1.2；其中逗号表示与，\|表示或，与的优先级较高
- 使用通配符，如1.0.*，相当于>=1.0,<1.1
- 语义化版本(Semantic Versioning)，或者叫下一个重要版本，如~1.2表示>=1.2,<2.0、~1.2.3表示为>=1.2.3,<1.3
- 另一语义化版本^，与~不同的是，^1.2.3表示>=1.2.3,<2.0.0
- 稳定性标签：以@开头，例如@dev表示空的版本约束，1.0.*@beta，表示允许依赖一个不稳定的包(beta版本)
- 明确版本引用：#<ref>，ref表示版本控制的提交编号，如git为md5，dev-master#2eb0c0978d290a1c45346a1955188929cb4e5db7

<br/>
Composer会将已经安装在系统上的平台软件包，如php本身，php扩展，系统库等，看成一个虚拟的包

所以可以使用类似以下的require来约束版本号

```json
{
    "require":{
        "php":">=5.3.0",
        "hhvm":">=2.3.3",
        "ext-mongo":"*",
        "lib-curl":"*"
    }
}
```

##### require-dev

这个列表是为开发或测试等目的，额外列出的依赖。可以使用\-\-no-dev跳过对require-dev依赖的安装

##### autoload

可以composer.json里添加以下内容，来告诉Composer新的autoload规则，并重新执行```composer.phar install -vvv```

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

*testNs.php*

```php
<?php
include_once "vendor/autoload.php";

use \Ns1\Math;
var_dump(Math::sum(1,2));
```

这样autoload就会自动在与vendor同级目录下的Ns1里找到对应的\Ns1\Math类


##### name

只要包含了composer.json在你的项目中，那么它就是一个包。项目与所依赖包的区别仅仅是项目一般没有名字。

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

不是必须的，并且建议不填写，因为可以从版本库推导出版本号来

##### keyword,homepage,time,license,authors,support

分别表示项目的相关信息，

- keyword:项目的关键字，用于搜索和过滤
- homepage:项目的主页
- time:版本发布时间
- license:许可协议
- authors:作者信息，为一个数组对象，可以包含以下信息name,email,homepage,role
- support:获取项目支持的向相关信息对象，可以包含以下信息email,issues,forum,wiki,irc,source

##### type

包的安装类型，默认为library，这种类型会简单的把代码复制到vendor

不同的类型会对应不同的处理，除了内置类型，还可以自定义类型，这就要求项目能够识别此类型，并进行对应安装

##### repositories

composer的资源库有多种类型，下面逐一介绍每一种类型的特点

*composer类型*

composer的默认源地址即为此类型，如下

```json
{
    "repositories": [
      {
        "type": "composer",
        "url":  "https://packagist.org/"
      }
    ]
}
```

这种类型的源都会在网站的根路径下存放有packages.json，表示这个源的所有资源（或者为include相关的申明）

如: https://packagist.org/packages.json

可以使用[Satis](https://github.com/composer/satis)和[packagist](https://github.com/composer/packagist)来搭建自己的composer源

*VCS类型*

composer支持git、svn等多种包管理，以下以git为例

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

testRepo.php

```php
<?php
include_once "vendor/autoload.php";
use \Phplib\FileLineIterator;

$t = new FileLineIterator(__DIR__ . "/testRepo.php");
foreach($t as $k=>$v){
    var_dump($k, $v);
}
```

*Package自定义源*

```json
{
    "repositories": [
        {
            "type": "package",
            "package": {
                "name": "smarty/smarty",
                "version": "3.1.7",
                "dist": {
                    "url": "http://www.smarty.net/files/Smarty-3.1.7.zip",
                    "type": "zip"
                },
                "source": {
                    "url": "http://smarty-php.googlecode.com/svn/",
                    "type": "svn",
                    "reference": "tags/Smarty_3_1_7/distribution/"
                },
                "autoload": {
                    "classmap": ["libs/"]
                }
            }
        }
    ],
    "require": {
        "smarty/smarty": "3.1.*"
    }
}
```

不建议使用这种方式，因为他无法更新，除非手动修改这里的version和dist相关信息

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

```composer.phar init```会一步引导创建composer.json文件

##### install

composer install 会读取当前目录下的composer.json文件，处理依赖关系，安装到vendor目录下

如果目录下存在composer.lock文件，则会从此文件读取依赖，如果没有composer.lock，Composer将在处理完之后创建

常用参数:

- \-\-prefer-source，\-\-prefer-dist：表示从版本控制源安装还是从分发版本安装
- \-\-dev：安装require-dev字段列出来的依赖(默认)
- \-\-no-dev：不安装require-dev字段列出来的依赖

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
composer.phar search monolog
```

##### show

列出项目中依赖的包

```
composer.phar show
```

常用参数 :

- \-\-installed (\-i): 列出已安装的依赖包。
- \-\-platform (\-p): 仅列出平台软件包（PHP 与它的扩展）。
- \-\-self (\-s): 仅列出当前项目信息。

#### 总结

以上为composer常见的使用方式和配置方法，后续针对性补充psr-4标准，自搭建资源库等内容

参考文档

[官方入门简介](http://docs.phpcomposer.com/00-intro.html)
[英文官方文档](https://getcomposer.org/doc/articles/versions.md#caret-version-range)
