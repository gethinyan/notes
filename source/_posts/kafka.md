---
title: Kafka 初体验
tags:
  - CentOS
  - Kafka
  - php
date: 2019-01-16 15:32:10
---

# `Kakfa` 简介

`Apache Kafka` 是一个分布式流处理平台

## 流处理平台三种特性

- 可以让你发布和订阅流式的记录。这一方面与消息队列或者企业消息系统类似
- 可以储存流式的记录，并且有较好的容错性
- 可以在流式记录产生时就进行处理

## `Kafka` 适用场景

- 构造实时流数据管道，它可以在系统或应用之间可靠地获取数据（相当于 message queue）
- 构建实时流式应用程序，对这些流数据进行转换或者影响（就是流处理，通过 kafka stream topic 和 topic 之间内部进行变化）

## `Kafka` 四个核心 API

### Producer API

The Producer API 允许一个应用程序发布一串流式的数据到一个或者多个 Kafka topic

### Consumer API

The Consumer API 允许一个应用程序订阅一个或多个 topic ，并且对发布给他们的流式数据进行处理

### Streams API

The Streams API 允许一个应用程序作为一个流处理器，消费一个或者多个 topic 产生的输入流，然后生产一个输出流到一个或多个 topic 中去，在输入输出流中进行有效的转换

### Connector API

The Connector API 允许构建并运行可重用的生产者或者消费者，将 Kafka topics 连接到已存在的应用程序或者数据系统。比如，连接到一个关系型数据库，捕捉表（table）的所有变更内容

## `Kafka` 依赖环境

- [Gradle](http://www.gradle.org/installation)
- [Java](http://www.oracle.com/technetwork/java/javase/downloads/index.html)

<!-- more -->

# 安装依赖环境

## 安装 `Java`

### 下载源码并解压

```bash
# 进入 root 用户根目录
$ cd /root
# 创建 source 文件夹用于存放源码压缩包
$ mkdir source && cd source
# 下载 Jdk 源码
$ wget https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz?AuthParam=1547191561_cd6fc31e988d398c5a0c796e2a033d89 -O jdk-8u191-linux-x64.tar.gz
# 解压
$ tar -zxvf jdk-8u191-linux-x64.tar.gz
# 移动到 root 用户根目录
$ mv jdk-11.0.1 /root/jdk
```

### 配置 `Path`

可以针对全局配置文件 `/etc/profile` 添加 `jdk` 的 `bin` 和 `jre` 文件夹的目录，同样也可以针对 `root` 用户配置用户的配置文件

- `/etc/profile`

```bash
# 在 export 前面添加下面代码
PATH=$PATH:/root/jdk/bin:/root/jdk/jre
```

- `~/.bash_profile`

```bash
# 在 export 前面添加下面代码，也可以就在 PATH= 后面添加 :/root/jdk/bin:/root/jdk/jre
PATH=$PATH:/root/jdk/bin:/root/jdk/jre
```

> 在配置好了之后别忘了使用 `source <profile path>` 命令让新配置文件生效

## 安装 `Gradle`

### 下载源码并解压

```bash
# 进入 source 文件夹
$ cd /root/source
# 下载 Gradle 源码
$ wget https://downloads.gradle.org/distributions/gradle-5.1.1-bin.zip
# 安装 unzip 命令（已安装请忽略）
$ yum install unzip
# 解压
$ unzip gradle-5.1.1-bin.zip
# 移动到 root 用户根目录
$ mv gradle-5.1.1 /root/gradle
```

> `gradle -v`
>
> ```bash
> ------------------------------------------------------------
> Gradle 5.1.1
> ------------------------------------------------------------
>
> Build time:   2019-01-10 23:05:02 UTC
> Revision:     3c9abb645fb83932c44e8610642393ad62116807
>
> Kotlin DSL:   1.1.1
> Kotlin:       1.3.11
> Groovy:       2.5.4
> Ant:          Apache Ant(TM) version 1.9.13 compiled on July 10 2018
> JVM:          1.8.0_191 (Oracle Corporation 25.191-b12)
> OS:           Linux 3.10.0-957.1.3.el7.x86_64 amd64
> ```

### 配置 `Path`

同 `Java` 的配置方式，只需把 `Gradle` 的 `bin` 目录 `/root/gradle/bin` 加入 `PATH`即可

```bash
PATH=$PATH:/root/gradle/bin
```

# 安装 `Kafka`

## 下载源码并解压

```bash
# 下载 Kafka 源码
$ wget http://archive.apache.org/dist/kafka/2.1.0/kafka_2.11-2.1.0.tgz
# 解压源码
$ tar -zxvf kafka_2.11-2.1.0.tgz
# 移动到指定目录
$ mv kafka_2.11-2.1.0 /path/to/kafka
```

## 启动服务器

> 下面的命令都是在 `Kafka` 的根目录运行的，请先进入 `Kafka` 的根目录

### 启动 `ZooKeeper` 服务器

```bash
$ bin/zookeeper-server-start.sh config/zookeeper.properties &
```

### 启动 `Kafka` 服务器

```bash
$ bin/kafka-server-start.sh config/server.properties &
```

### 创建一个 `topic`

```bash
$ bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

### 查看 `topic`

```bash
$ bin/kafka-topics.sh --list --zookeeper localhost:2181
__consumer_offsets
test
```

### 发送消息

运行 `producer`（生产者），然后在控制台输入一些消息以发送到服务器

```bash
$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
>This is a message
>This is another message
```

### 接收消息

`Kafka` 还有一个命令行 `consumer`（消费者），将消息转储到标准输出

```bash
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
This is a message
This is another message
```

<!--### 设置多代理集群-->

# `php` 处理 `Kafka` 消息

## 编译安装 `librdkafka`

```bash
# 下载 librdkafka 源码
$ wget https://github.com/edenhill/librdkafka/archive/v0.11.6.tar.gz
# 解压源码
$ tar -zxvf v0.11.6.tar.gz
# 进入 librdkafka 文件夹
$ cd librdkafka-0.11.6
# 编译安装 librdkafka
$ ./configure
$ make && make install
```

## 编译安装 `php-rdkafka` 扩展

```bash
$ su work
$ cd /home/work/source
# 下载 php-rdkafka 源码
$ wget https://github.com/arnaud-lb/php-rdkafka/archive/3.0.5.tar.gz
# 解压源码
$ tar -zxvf 3.0.5.tar.gz
# 进入 php-rdkafka 文件夹
$ cd php-rdkafka-3.0.5
# 运行 phpize 命令，写全 phpize 的路径
$ /home/work/orp/php/bin/phpize
# 编译安装 php-rdkafka
$ ./configure --with-php-config=/home/work/orp/php/bin/php-config
$ make all -j 5 && make install
```

## 配置 `php.ini`

### 编辑 `php.ini` 文件

```bash
# 把安装好的扩展加加入 php.ini
extension=rdkafka.so
```

### 重启 `php-fpm`

```bash
# 查看 php-fpm 进程
$ ps -ef | grep php
work      6817     0  0 08:19 ?        00:00:00 php-fpm: master process (/home/work/orp/php/etc/php-fpm.conf)
work      6818  6817  0 08:19 ?        00:00:00 php-fpm: pool www
work      6819  6817  0 08:19 ?        00:00:00 php-fpm: pool www
work      6840  2732  0 08:24 pts/1    00:00:00 grep php
# 重启 php-fpm
$ kill -USR2 38
```

> 现在打开 `phpinfo` 页面搜索 `rdkafka` 扩展可以看到我们已经成功安装了 `rdkafka` 扩展，下面我们将在实战中使用到 `Kafka`

## 生产者 `Producer`

### `php` 代码

```php
<?php

$rk = new RdKafka\Producer();
$rk->setLogLevel(LOG_DEBUG);
// 配置 Kafka 的 ip 地址，我这里是容器调用宿主机里的 Kafka
$rk->addBrokers('172.17.0.1');

$topic = $rk->newTopic('test');
$topic->produce(RD_KAFKA_PARTITION_UA, 0, 'Message payload');
```

### 运行生产者代码

```bash
$ /home/work/orp/php/bin/php /home/work/orp/webroot/producer.php
```

### 运行 `Kafka` 消费者查看

```bash
$ cd /root/kafka
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
Message payload
Message payload
```

## 消费者 `Consumer`

### Low-level consumer

#### `php` 代码

```php
<?php

$rk = new RdKafka\Consumer();
$rk->setLogLevel(LOG_DEBUG);
$rk->addBrokers('172.17.0.1');

$topic = $rk->newTopic('test');
// The first argument is the partition to consume from.
// The second argument is the offset at which to start consumption. Valid values
// are: RD_KAFKA_OFFSET_BEGINNING, RD_KAFKA_OFFSET_END, RD_KAFKA_OFFSET_STORED.
$topic->consumeStart(0, RD_KAFKA_OFFSET_BEGINNING);

while (true) {
    // The first argument is the partition (again).
    // The second argument is the timeout.
    $msg = $topic->consume(0, 1000);
    if ($msg->err) {
        echo $msg->errstr(), "\n";
        break;
    } else {
        echo $msg->payload, "\n";
    }
}
```

#### 运行低级消费者 `php` 代码

> 可以看到我们已经成功的接收到了生产者生产的消息

```bash
$ /home/work/orp/php/bin/php consumer.php
Message payload
Message payload
Broker: No more messages
```

### High-level consumer

#### `php` 代码

```php
<?php

$conf = new RdKafka\Conf();

// Set a rebalance callback to log partition assignments (optional)
$conf->setRebalanceCb(function (RdKafka\KafkaConsumer $kafka, $err, array $partitions = null) {
    switch ($err) {
        case RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS:
            echo 'Assign: ';
            var_dump($partitions);
            $kafka->assign($partitions);
            break;

         case RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS:
             echo 'Revoke: ';
             var_dump($partitions);
             $kafka->assign(null);
             break;

         default:
            throw new \Exception($err);
    }
});

// Configure the group.id. All consumer with the same group.id will consume
// different partitions.
$conf->set('group.id', 'myConsumerGroup');

// Initial list of Kafka brokers
$conf->set('metadata.broker.list', '172.17.0.1');

$topicConf = new RdKafka\TopicConf();

// Set where to start consuming messages when there is no initial offset in
// offset store or the desired offset is out of range.
// 'smallest': start from the beginning
$topicConf->set('auto.offset.reset', 'smallest');

// Set the configuration to use for subscribed/assigned topics
$conf->setDefaultTopicConf($topicConf);

$consumer = new RdKafka\KafkaConsumer($conf);

// Subscribe to topic 'test'
$consumer->subscribe(['test']);

echo "Waiting for partition assignment... (make take some time when\n";
echo "quickly re-joining the group after leaving it.)\n";

while (true) {
    $message = $consumer->consume(120 * 1000);
    switch ($message->err) {
        case RD_KAFKA_RESP_ERR_NO_ERROR:
            var_dump($message);
            break;
        case RD_KAFKA_RESP_ERR__PARTITION_EOF:
            echo "No more messages; will wait for more\n";
            break;
        case RD_KAFKA_RESP_ERR__TIMED_OUT:
            echo "Timed out\n";
            break;
        default:
            throw new \Exception($message->errstr(), $message->err);
            break;
    }
}
```

#### 运行高级消费者 `php` 代码

```bash
$ /home/work/orp/php/bin/php highConsumer.php
object(RdKafka\Message)#6 (7) {
  ["err"]=>
  int(0)
  ["topic_name"]=>
  string(4) "test"
  ["partition"]=>
  int(0)
  ["payload"]=>
  string(15) "Message payload"
  ["len"]=>
  int(15)
  ["key"]=>
  NULL
  ["offset"]=>
  int(23)
}
object(RdKafka\Message)#5 (7) {
  ["err"]=>
  int(0)
  ["topic_name"]=>
  string(4) "test"
  ["partition"]=>
  int(0)
  ["payload"]=>
  string(15) "Message payload"
  ["len"]=>
  int(15)
  ["key"]=>
  NULL
  ["offset"]=>
  int(24)
}
No more messages; will wait for more
```

## 遇到的问题

### 容器内访问不到容器外的端口

#### 问题描述

在运行消费者、生产者的时候，报错最多的就是 `'hostname:9092': Name or service not known`，最开始使用的是 `172.17.0.1` 宿主机的 `ip` 去调用的，出现的上述问题，后又用外网 `ip` 去调用，因为安全组导致端口未暴露，所以在阿里云管理控制台的安全组加了 9092，加了安全组在线工具检测 9092 端口是打开状态，但是在运行生产者代码的时候还是会报错 `'hostname:9092': Name or service not known`，于是我自闭了

#### 解决方案

其实通过报错 `'hostname:9092': Name or service not known` 我们可以得知系统不知道这个 `hostname`，于是我尝试性的在 `/etc/hosts` 文件里面加了一行 `172.17.0.1 hostname`，然后重启网络，莫名其妙的就成功了，取消自闭模式

### 关闭防火墙导致访问不到外网

#### 问题描述

因为不知道是不是因为防火墙的问题，所以就偷偷的把防火墙给关了，结果后面发现容器里面连不上外网，发现这个问题是看到同事在本地使用 `127.0.0.1` 调用成功了，所以打算在容器里装上 `Kafka` 然后用 `127.0.0.1` 调用，结果连不上网无法 `wget` 下载源码包

#### 解决方案

重启 `docker`，然后 `dokcer start container` 启动容器即可，经过上机测试，需要注意的是 `docker` 容器能不能访问到外网跟 `docker` 启动的那一刻宿主机的防火墙状态有关系，宿主机防火墙是关闭的那么开启之后需要重启 `docker` 容器才能访问外网，反之同理
