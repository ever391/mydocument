##一、安装go环境

这里偷个懒，直接用官网发布的二进制文件了，老规矩 下载 解压 配置环境变量三步走。

先在官网找到自己对应的系统下载二进制文件，博主这里用的是x86-64的Linux。

```
wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz
```
之后解压到对应文件夹，位置随意，本文选择解压到 /usr/local。如果跟本文不一样记得也要更改对应的环境变量。

```
tar -C /usr/local/ -xvf go1.15.6.linux-amd64.tar.gz
```
最后配环境变量。
```
#打开环境变量配置文件
vim /etc/profile
#加入这一句
export PATH=$PATH:/usr/local/go/bin
#保存退出后更新环境变量
source /etc/profile
```
之后输入 go version，如果显示出go的版本信息就可以了。
![](https://blog.northtower.top/usr/uploads/2021/01/3198519738.png)

##二、安装普罗米修斯（Promethus）与监控插件node_exporter
1. 下载并修改普罗米修斯
普罗米修斯的官网在这里，推荐选择最新版本安装。
```
#下载二进制文件
wget https://github.com/prometheus/prometheus/releases/download/v2.24.0/prometheus-2.24.0.linux-amd64.tar.gz
#解压
tar -C /usr/local/ -xvf prometheus-2.24.0.linux-amd64.tar.gz
#创建软链接
ln -sv /usr/local/prometheus-2.24.0.linux-amd64/ /usr/local/Prometheus
```
普罗米修斯的默认配置文件在 /usr/local/Prometheus/prometheus.yml，这里简单介绍一下配置文件格式。

以监控使用 node-exporter的linux机器为例，
```
- job_name: 'Prometheus'
  static_configs:
    - targets: ['192.168.0.1:9100']
      labels:
      instance: Prometheus
```
其中 job_name决定了被监控机所在的分组，targets为被监控机的地址和 node-exporter端口。如果要在同一个分组下添加多台监控机器只需要添加多个 - targets即可。

2. 运行测试并创建系统服务
执行以下命令使普罗米修斯在前台启动。
```
/usr/local/Prometheus/prometheus --config.file=/usr/local/Prometheus/prometheus.yml
```
此时访问vps_ip:9090查看是否启动成功。

之后创建系统service文件。这里可以自定义普罗米修斯的访问端口与监控数据保存文件夹。
```
#创建数据保存文件夹
mkdir /usr/local/Prometheus/data
#创建service文件
vim /usr/lib/systemd/system/prometheus.service
#加入以下内容
[Unit]
Description=Prometheus Monitoring System
Documentation=http://prometheus.com(这个要写url)

[Service]
ExecStart=/usr/local/Prometheus/prometheus \
--config.file=/usr/local/Prometheus/prometheus.yml --web.enable-admin-api \
--web.listen-address=:9090 \
--storage.tsdb.path=/usr/local/Prometheus/data

[Install]
WantedBy=multi-user.target
```
最后启动普罗米修斯，查看状态，并设置开机启动。
```
systemctl start prometheus.service
systemctl status prometheus.service
systemctl enable prometheus.service
```
3. 被控机配置node_exporter
首先下载最新版本的二进制文件并解压。
```
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz -C /usr/local/
```
之后创建运行用户与用户组，并配置service文件。
```
sudo groupadd -r prometheus
sudo useradd -r -g prometheus -s /sbin/nologin -M -c "prometheus Daemons" prometheus

cat << EOF > /usr/lib/systemd/system/node_exporter.service
[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/node_exporter-1.0.1.linux-amd64/node_exporter

[Install]
WantedBy=multi-user.target

[Unit]
Description=node_exporter
After=network.target
EOF

```
最后启动node_exporter，查看状态并设置开机启动。之后不要忘记去普罗米修斯的配置文件里加入对应被监控机的地址与端口。

##三、使用Grafana连接Prometheus
1.安装Grafana
在官网下载最新版本二进制文件并安装。
```
wget https://dl.grafana.com/oss/release/grafana-7.3.7-1.x86_64.rpm
sudo yum install grafana-7.3.7-1.x86_64.rpm
```
运行并配置开机启动。
```
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server.service
sudo /bin/systemctl start grafana-server.service
```
之后访问vps_ip:3000就能看到Grafana的面板了，初始的用户名与密码都是 admin。
![](https://blog.northtower.top/usr/uploads/2021/01/1202350842.png)
Grafana登录页
初始：admin/admin

2.配置Grafana对接普罗米修斯数据源
登录后进入主界面，点击红圈内按钮添加第一个数据源。

![](https://blog.northtower.top/usr/uploads/2021/01/3272152421.png)
添加数据源

之后选择第一项普罗米修斯数据源。

![](https://blog.northtower.top/usr/uploads/2021/01/1664087566.png)
普罗米修斯数据源

这里只需要添加 HTTP URLs为本地的普罗米修斯端口就可以了，其他保持默认。

![](https://blog.northtower.top/usr/uploads/2021/01/2515886903.png)
修改数据源

最后从面板左侧的任务栏选择 Manage，然后点击 Improt添加新的监控模板即可。

![](https://blog.northtower.top/usr/uploads/2021/01/3331274119.png)
添加监控模板

模板1
模板1

这里推荐几个模板：

https://grafana.com/grafana/dashboards/8919

https://grafana.com/grafana/dashboards/9276

https://grafana.com/grafana/dashboards/1860

最后，推荐修改一下Grafana的配置文件将Grafana运行在本地内网上，然后通过本地反向代理来使用SSL访问前端面板。配置文件地址为 /etc/grafana/grafana.ini。