# Docker国内源镜像配置说明
### 一、下载docker
```bash
# 安装docker所需的工具, 安装需要的软件包， yum-util 提供yum-config-manager功能，另外两个是devicemapper驱动依赖的。
yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置阿里云的docker源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 查看可安装的版本
yum list docker-ce --showduplicates | sort -r
# 指定安装这个版本的docker-ce
yum install -y docker-ce
# or 
yum install -y docker-ce-18.09.9-3.el7
# 启动docker
systemctl enable docker && systemctl start docker

# 查看docker版本
docker version
```
### 二、修改docker国内源镜像配置
```bash
   1.修改daemon.json文件， 如果没有就创建一个
   vim /etc/docker/daemon.json
   aaaa{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": {
   "max-file": "3",
   "max-size": "100m"
   },
   "storage-driver": "overlay2",
   "storage-opts": [
   "overlay2.override_kernel_check=true"
   ],
   "registry-mirrors": ["https://www.docker-cn.com"]
   }
   
   # 重启docker
   systemctl daemon-reload && systemctl restart docker
   
   # 开机启动
   systemctl enable docker.service
```

### 三、 问题
    如果docker重启失败提示start request repeated too quickly for docker.service
    应该是centos的内核太低内核是3.x，不支持overlay2的文件系统，移除下面的配置
    "storage-driver": "overlay2",
    "storage-opts": [
    "overlay2.override_kernel_check=true"
    ]
