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

```
module(load="imudp")   
module(load="omelasticsearch")

input(type="imudp" port="514")

template(name="estp" type="list" option.json="on") {
		constant(value="{")
		constant(value="\"timestamp\":\"")			property(name="timereported" dateFormat="rfc3339")
		constant(value="\",\"message\":\"")			property(name="msg")
		constant(value="\",\"hostname\":\"")		property(name="hostname")
		constant(value="\",\"fromhost\":\"")		property(name="fromhost")
		constant(value="\",\"fromhostIP\":\"")	property(name="fromhost-ip")
		#constant(value="\",")                  property(name="$!all-json" position.from="2")
}

template(name="searchIndex" type="string" string="crawler-%$year%.%$month%.%$day%")

action(type="omelasticsearch" server="estp" serverport="9200" searchIndex="searchIndex" searchType="events" dynsearchIndex="on" bulkmode="on" template="estp" action.resumeretrycount="-1")
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

  





