# Jaeger 部署启动文档

### 一、jaeger组件介绍：

`jaeger-client`：jaeger 的客户端，实现了opentracing协议；

`jaeger-agent`：jaeger client的一个代理程序，client将收集到的调用链数据发给agent，然后由agent发给collector；

`jaeger-collector`：负责接收jaeger client或者jaeger agent上报上来的调用链数据，然后做一些校验，比如时间范围是否合法等，最终会经过内部的处理存储到后端存储；

`jaeger-query`：专门负责调用链查询的一个服务，有自己独立的UI；

`jaeger-ingester`：中文名称“摄食者”，可用从kafka读取数据然后写到jaeger的后端存储，比如Cassandra和Elasticsearch；

`spark-job`：基于spark的运算任务，可以计算服务的依赖关系，调用次数等；



其中`jaeger-collector`和`jaeger-query`是必须的，其余的都是可选的，我们没有采用agent上报的方式，而是让客户端直接通过endpoint上报到collector。

### 二、启动命令

#### 1. Jaeger-Collector

```bash
 ./jaeger-collector  --span-storage.type=elasticsearch --es.server-urls=http://{ES地址:9200} --es.num-replicas=0  --log-level=info   --sampling.strategies-file=strategies.json --collector.zipkin.http-port=9411 --collector.queue-size=9999
```

     – es.server-urls:elasticsearch地址，逗号隔开
     – sampling.strategies-file=strategies.json 采样策略，需要建立一个strategies.json文件
     – collector.queue-size=9999 队列大小，默认2000，可以不加
     – collector.zipkin.http-port 适配下zipkin

#### 2. Jaeger-Agent

```bash
./jaeger-agent   --reporter.grpc.host-port={ES地址}:14250  --log-level=info  
```
    –reporter.grpc.host-port：jaeger-collector地址

#### 3. Jaeger-Query

```bash
jaeger-query --span-storage.type=elasticsearch  --es.server-urls=http://{ES地址:9200} 
```
