# Kafka核心概念

## 1.消息(Message/Record)

```bash
Kafka传输和存储的基本单元
构成：
	键(Key)：可选，用于消息路由，用于消息路由(确保具有相同key的消息发送到同一分组)和数据压缩
	值(Value)：消息的实际内容，通常是字节数组
	时间戳(Timestamp)：消息产生或被Broker接受的时间
	偏移量(Offset)：消息在分区中的唯一、有序的标识符
```

## 2.主题(Topic)

```bash
消息的类别名称，是生产者发布消息和消费者订阅消息
发布/订阅模型：生产者将消息发送到特定的Topic，多个消费者可以独立地订阅同一个Topic，互不影响
```

## 3.分区(Partition)

```bash
为了实现水平扩展、高吞吐量和容错性，每个Topic会被划分为一个或多个有序的日志序列，即分区

数据存储：Topic的所有消息分散存储在它的所有分区中

顺序性：消息在单个分区内是严格有序的，即Producer写入的顺序和Consumer读取的顺序一致，但Topic整体而言是无需的

并发度：分区是Kafka并行处理的最小单位，Consumer Group的消费并行度受限于Topic的分区数
```

## 4.偏移量(Offset)

```bash
消息在分区日志中唯一、单调递增的ID
作用：
	定位：消费者使用Offset来准确地标记和跟踪它在每个分区中已经消费到地位置
	控制：消费者可以根据需要，通过重置Offset来从分区日志地任意位置重新开始消费
存储：Kafka Broker不会跟踪消费者已经消费了哪些消息，这个消费进度(即每个分区地最新Offset)是由消费者自己维护并提交给Kafka内部地Topic存储的
```

## 5.代理(Broker)和集群(Cluster)

```bash
Broker是运行Kafka读物的一个服务器节点实例
多个Broker共同工作，组成一个Kafka集群
Broker负责存储分区数据，处理生产者和消费者发送的请求，并负责副本的管理
```

## 6.副本(Replica)和Leader

```bash
副本书堆分区数据的备份，为了保证数据的可靠性和高可用性，Kafka允许将一个分区的消息复制到多个Broker上

领导者(Leader)：每个分区都有一个Leader副本，所有的读写请求都必须通过Leader进行

追随者(Follower)：其他都是副本Follower，它们被动地从Leader复制数据，保持与Leader的同步

作用：当Leader发生故障，Kafka会自动从同步的Follower中选举一个新的Leader，确保服务不中断
```

## 7.生产者(Producer)

```bash
客户端应用程序，负责发布消息到指定的Topic
生产者负责将消息写入Topic的哪个分区中，选择策略通常基于消息的Key进行散列，保证相同Key的消息在同一分区，或者采用轮询的方式

数据保证：Producer通过配置acks参数控制消息的可靠性级别
```

## 8.消费者(Consumer)和消费者组(Consumer Group)

```bash
消费者（Consumer）： 客户端应用程序，负责订阅 Topic 并拉取消息进行处理。
消费者组（Consumer Group）： 一组共享同一个 Group ID 的消费者实例。这是 Kafka 实现可伸缩消费和负载均衡的核心机制。

消费模式：
    负载均衡： 在一个 Group 内，每个分区只能被一个消费者实例消费。通过将分区均匀分配给 Group 内的消费者，实现了消息的并行处理和负载均衡。
    广播（多订阅者）： 不同的 Consumer Group 之间是独立的。一个 Topic 的所有消息可以被多个不同的 Consumer Group 独立且完整地消费（类似于传统发布/订阅模式）
```



# Kafka的两种模式

