---
layout: post
title: Java、MySQL、utf8mb4的困惑
date: 2019-11-04
categories:
  - Tech
description: 众所周知，要在MySQL中支持Emoji等Unicode字符，需要将MySQL的字符集设置成utf8mb4。为了能让客户端也能正常更新写入这些字符，不仅是表字段的字符集，连接的字符集也要设置对才行。
image: "{{ site.baseurl }}/assets/images/mysql-emoji.jpg"
image-sm: "{{ site.baseurl }}/assets/images/mysql-emoji.jpg"
---

### 事起之由

同事反馈Java程序中将Emoji表情内容写入MySQL报无效的不合法的字符串值：

```
org.springframework.jdbc.UncategorizedSQLException: 
### Error updating database.  Cause: java.sql.SQLException: Incorrect string value: '\xF0\x9F\x92\xA6 \xE6...' for column 'name' at row 1
...
```

以常年PHP+MySQL排坑的经验，加之报错的地方是一个Emoji字符，百分之百是因为[MySQL老生常谈的utfmb4的问题](http://seanlook.com/2016/10/23/mysql-utf8mb4/)。

查了一下数据库的建表语句，对应字段的字符集确实已经是utf8mb4了，那问题就出现在Java连接MySQL的时候设置的字符集设置错了。在PHP中直接在连接完成之后执行set names utf8mb4就行了。Java肯定也有类似的办法。

以为这个问题会很容易解决掉，不料第二天来的时候发现同事吐槽这个Java的MySQL连接太难用了，配置时只能设置utf8无法设置utf8mb4，搞得每一次在执行查询的时候还要执行一次set names utf8mb4。神烦！

这听起来很奇怪，不会写出啥幺蛾子吧。我得去看看。

### 现场重现

场景还原后大概是个样子的:

MySQL的test.config表格式：

```sql
CREATE TABLE `config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

关键Spring Boot框架文件：

配置文件：application.yml

```yaml
# 省略了额外的配置
spring:
  datasource:
    test:
      driverClassName: com.mysql.jdbc.Driver
      url: jdbc:mysql://localhost:3306/test?zeroDateTimeBehavior=convertToNull&autoReconnect=true&failOverReadOnly=false&maxReconnects=3&serverTimezone=GMT%2B8&useUnicode=true&characterEncoding=UTF-8
      username: root
      password:
      hikari:
        connectionTimeout: 6000
        connectionTestQuery: SELECT 1
        connectionInitSql: set names utf8mb4
        minIdle: 1
        maxPoolSize: 5
        maxLifetime: 1800000
```

MySQL配置生成DataSource的配置文件：config/MysqlConfig.java

```java
@Configuration
@MapperScan(basePackages = {"lab.mapper", "lab.model"})
public class MysqlConfig {

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.test")
    @Primary
    public DataSourceProperties getDataSourceProperties(){
        return new DataSourceProperties();
    }

    @Bean
    @Primary
    public DataSource getDataSource(){
        return getDataSourceProperties().initializeDataSourceBuilder()
                .type(HikariDataSource.class).build();
    }

    @Bean
    @Primary
    public SqlSessionFactory getSqlSessionFactory(DataSource dataSource) throws Exception{
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource);
        return sqlSessionFactoryBean.getObject();
    }

    @Bean
    @Primary
    public SqlSessionTemplate getSqlSessionTemplate(SqlSessionFactory sqlSessionFactory){
        return new SqlSessionTemplate(sqlSessionFactory);
    }

    @Bean
    @Primary
    public DataSourceTransactionManager getDataSourceTrasactionManager(DataSource dataSource){
        return new DataSourceTransactionManager(dataSource);
    }
}
```

数据库Model文件：model/Config.java

```java
@Data
@Table(name = "config")
public class Config {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
}
```

Mapper文件：mapper/ConfigMapper.java

```java
public interface ConfigMapper extends Mapper<Config>, MySqlMapper<Config>, DeleteByIdsMapper<Config> {
    @Select("set names utf8mb4")
    void setNamesUtf8mb4();
}
```


对应的业务代码换成了测试用例：

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class MysqlTest {
    @Autowired
    ConfigMapper configMapper;

    @Test
    public void utf8mb4Test() {
        Config c = configMapper.selectByPrimaryKey(1);
        // 以下字符是emoji
        c.setName("\uD83D\uDE04 \uD83D\uDE05 \uD83D\uDE06");
        configMapper.setNamesUtf8mb4();
        configMapper.updateByPrimaryKey(c);
    }
}
```

### 顺利解决

我一看，这可还行，总不能以后在每一个插入和更新语句之前都执行setNamesUtf8mb4()吧。这都9102年了，库里肯定提供了设置客户端编码集的方法的。

首先从配置的jdbc.url出发，发现有一个characterEncoding配置的是UTF-8，能否配置成UTF-8MB4或者UTF8MB4呢？

不可以，直接报错无法建立连接。找到[官方文档](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-charsets.html)，从其提供的表格来看，只有UTF-8可选。

但其中一条格外瞩目：

![]({{ site.baseurl }}/assets/images/mysql-encoding.png)

这不是说mysql-connector大于5.1.47版本就自动从utf8升级到utf8mb4了吗？

我看了一眼项目build.gradle的配置：

```
    compile 'mysql:mysql-connector-java:5.1.14'
```

果然还是5.1.14，太低了。马上着手升级到5.1.47。

更新完gradle之后再去掉configMapper.setNamesUtf8mb4(); 这时再跑这个case，过了！


### 再深入些

貌似很优雅地解决了问题，那有没有其它的方案呢？毕竟升级版本号这个事情不是小事，如果有其它诸如配置文件这样影响小的方案会更好。

在读之前提到的[官方文档](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-charsets.html)时，又发现一处另人惊喜的描述：

>    The character encoding between client and server is automatically detected upon connection (provided that the Connector/J connection properties characterEncoding and connectionCollation are not set). You specify the encoding on the server using the system variable character_set_server (for more information, see Server Character Set and Collation). The driver automatically uses the encoding specified by the server. For example, to use the 4-byte UTF-8 character set with Connector/J, configure the MySQL server with character_set_server=utf8mb4, and leave characterEncoding and connectionCollation out of the Connector/J connection string. Connector/J will then autodetect the UTF-8 setting.

大意是在没有设置characterEncoding的情况下会根据服务端设置的character_set_server值来设置客户端的编码。

看了一眼MySQL服务端的这个值：

```
mysql> show variables like "character_set_server";
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| character_set_server | utf8  |
+----------------------+-------+
```

果然只是utf8，我试着将其改成utf8mb4：

在my.cnf里添加一行：

```
character-set-server = utf8mb4
```

重启了mysqld，使用客户端连接上并查看character-set-server确定变成utf8mb4之后，将mysql-connector的版本号回滚到了5.1.14，再更新gradle，又跑一下case，又又过了！

### 更深入些

之前的办法在线上很难操作，实用性还不如升级mysql-connector。重启MySQL这样的操作一般几年都不可能操作一次吧。

重新将注意力放到了配置上，发现一个神奇的地方，spring.datasource.test.hikari这个配置下面有一个connectionInitSql，而且已经配置了值为set names utf8mb4。

从名字的意义来看，这肯定是连接完之后初使化的执行语句，但是为什么没有生效呢？

从各个类上查找与connectionInitSql相关的类，最终在HikariDataSource的父类HikariConfig上找到了对应的属性，所以这个配置应该作用于DataSource上的。

而我们的配置中这个属性附加在DataSourceProperties上，而DataSourceProperties并没有对应的成员来承接这个配置。所以正确的配置方法是在getDataSource函数上添加@ConfigurationProperties(prefix = "spring.datasource.test.hikari")来将对应的属性设置到HikariConfig上：

```java
    @Bean
    @Primary
    @ConfigurationProperties(prefix = "spring.datasource.test.hikari")
    public DataSource getDataSource(){
        return getDataSourceProperties().initializeDataSourceBuilder()
                .type(HikariDataSource.class).build();
    }
```

果然添加完这个注解之后，把MySQL的配置回滚重启，这时的case也能通过了！这才是目前最简单的方法！

### 总结

MySQL碰到Emoji无法写入或者有关utf8mb4编码问题时的解决方案：

● 升级mysql-connector，5.1.47及以上的版本会在设置characterEncoding=UTF-8之后自动将编码升级成utf8mb4；

● 有条件重启mysql server的，可以在my.cnf里添加character-set-server设置成utf8mb4来设置默认的字符集；

● 最简单有效的办法就是配置数据库连接的初使调用语句，只要设置HikariDataSource的connectInitSql为set names utf8mb4，即可达到目的。


### 参考

[官方文档：Using Character Sets and Unicode](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-charsets.html)

[mysql/Java服务端对emoji的支持](https://segmentfault.com/a/1190000000616820)

[mysql-connector-java 插入 utf8mb4 字符失败问题处理分析](https://blog.arstercz.com/mysql-connector-java-%E6%8F%92%E5%85%A5-utf8mb4-%E5%AD%97%E7%AC%A6%E5%A4%B1%E8%B4%A5%E9%97%AE%E9%A2%98%E5%A4%84%E7%90%86%E5%88%86%E6%9E%90/)

[utf8mb4 in MySQL Workbench and JDBC](https://stackoverflow.com/questions/44591895/utf8mb4-in-mysql-workbench-and-jdbc)
