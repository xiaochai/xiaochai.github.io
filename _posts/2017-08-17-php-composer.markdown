---
layout: post
title: "PHP Composer的基本使用"
date: 2017-08-17
categories:
  - Tech
description: http://image.phpcomposer.com/logo/phpcomposer.png
image: http://image.phpcomposer.com/logo/phpcomposer.png
image-sm: 
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

### composer.json配置文件

##### require key

require包含包名称和包版本映射关系，而包名称又包含供应商名称和项目名称

如之前的composer.json，包名称monolog/monolog，此处的供应商名称和项目名称都为monolog，版本号为1.23.*

对于版本约束，见下面表格

- [Usage Instructions](doc/01-usage.md)
- [Handlers, Formatters and Processors](doc/02-handlers-formatters-processors.md)
- [Utility Classes](doc/03-utilities.md)
- [Extending Monolog](doc/04-extending.md)
- [Log Record Structure](doc/message-structure.md)





