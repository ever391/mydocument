# rsyslog 配置文件

### 1. Install syslog

- Centos

  ```bash
  cd /etc/yum.repos.d/
  wget http://rpms.adiscon.com/v8-stable-nightly/rsyslog-nightly.repo # for CentOS 7
  wget http://rpms.adiscon.com/v8-stable-nightly/rsyslog-nightly-rhel7.repo # for RHEL 7
  yum install rsyslog
  ```

  

- Mac

  ```
  brew install rsyslog
  ```

  

### 2. Install rsyslog-elasticsearch

```bash
yum install rsyslog-mmjsonparse rsyslog-mmutf8fix rsyslog-elasticsearch rsyslog-mmnormalize

```



### 3. ES配置

```# 加载必要模块
module(load="imudp")
module(load="mmjsonparse")     # JSON解析
module(load="mmutf8fix")
module(load="omelasticsearch") # ES输出

# 输入设置
input(type="imudp" port="514")


action(type="mmutf8fix")

# 带cookie参数解析CEE格式
action(type="mmjsonparse")  # 关闭会引发解析错误

#if $parsesuccess == "OK" then {
#   action(type="omfile" File="/var/log/rsyslog/jsonparseOK.log")
#}
#else if $parsesuccess == "FAIL" then {
#   action(type="omfile" File="/var/log/rsyslog/jsonparseErr.log")
#}

# 仅处理包含JSON数据的日志（例如来自应用的日志）
#if $programname == "your_app_name" and $msg contains "{" then {
#    mmjsonparse()                # 解析JSON内容
#    action(type="omelasticsearch")  # 触发ES转发
#      stop                         # 避免重复处理
#}


# ES输出模板（完全继承原始JSON）
template(name="estp" type="list") {
                constant(value="{")
                constant(value="\"timestamp\":\"")                      property(name="timereported" dateFormat="rfc3339")
                constant(value="\",\"hostname\":\"")                    property(name="hostname")
                constant(value="\",\"fromhost\":\"")                    property(name="fromhost")
                constant(value="\",\"fromhostIP\":\"")                  property(name="fromhost-ip")
                constant(value="\",")                                   property(name="$!all-json" position.from="2")    # position.from="2" 会过滤到外城的{}
}



# 索引模板（字母开头+日期）
template(name="searchIndex" type="string" string="taoshu-%$year%-%$month%-%$day%")

# ES输出配置
action(
    type="omelasticsearch"
    server="192.168.0.176"
    serverport="9200"
    searchIndex="searchIndex"
    dynsearchIndex="on"
    bulkmode="on"
    template="estp"
    action.resumeretrycount="-1"
#    usehttps="on"
#    uid="elastic"
#    pwd="_2ElrGwg+R234z2oCtrN"
#    tls.cacert="/etc/elasticsearch/es_ca.crt"
#    tls.mycert="/etc/elasticsearch/es-ca.pem"
    # 新增容错参数
```

### 3.Mysql配置

```
module(load="imudp")   
module(load="ommysql")

input(type="imudp" port="514")

template(name="sqltp" type="list" option.sql="on") {
	constant(value="inser into {table} (field....)")
	constant(value=" values ('")
	property(name="msg")
	constant(value="','")
	proprety....
	constant(value="','")
}

action(type="ommysql" server="192.168.1.2" serverport="3306" db="{dbname}" uid="{user}" pwd="{password}" template="sqltp")
```



### 4. 启动

```
rsyslogd -n -f ./rsyslog.conf
```



# Elaticsearch

### 1.下载安装

- WEB下载

```
https://elastic.co/cn/downloads/elasticsearch
```

- Mac

  ```
  brew install elasticsearch
  ```

  

### 2. 启动

```
brew service start elasticsearch
```



### 3. 配置文件

- 配置文件地址
  - 压缩包： 在解压包目录下config/elasticsearch.yml
- Mac
  - /usr/local/etc/elasticsearch/elasticsearch.yml





### 4.启动

 - 创建linux 帐户： elasticsearch

 - 安装JDK 1.8

 - Jdk8 HOME

 - ```
which java  
      
    ls -lrt /usr/bin/java  
      
    ls -lrt /etc/alternatives/java  
```
    
 - 

 - 设置JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.7.0.261-2.6.22.2.el7_8.x86_64/jre

 - 单机启动

    - ```bash
      cd /{安装目录}/elasticsearch
      ./bin/elasticsearch -E discovery.type=single-node
      ```

      

# kibana

### 1.下载安装

- WEB下载

```
https://elastic.co/cn/downloads/kibana
```

- Mac

  ```
  brew install kibana
  ```

  

### 2. 启动

```
brew service start kibana
```



### 3. 配置文件

- 配置文件地址
  - 压缩包： 在解压包目录下config/kibana.yml
- Mac
  - /usr/local/etc/kibana/kibana.yml

### 4. 修改配置文件

- 编辑配置文件第7行

  ```
  # server.host: "localhost"
  改为
  # server.host: "本机ip"
  ```

  





