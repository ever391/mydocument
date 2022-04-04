# K8S 安装部署文档

### 一. 服务器配置
1. 资源配置
    - master 1台 （必须要有公网IP）
    - node 3 台 (node节点服务器不需要公网IP）
    - 弹性IP
    - NAT
    - 配置好DNS
      ```
      cat <<EOF >> /etc/hosts
      192.168.1.128 k8s-master
      192.168.1.129 k8s-node001
      192.168.1.130 k8s-node002
      EOF
      ```

2. 服务主机名称修改
 - master
   - `hostnamectl --static set-hostname k8s-master`
   - `hostname` #查看主机名称 

 - node
 - `hostnamectl --static set-hostname k8s-node-001`

 3. 关闭防火墙
```bash
systemctl disable firewalld
systemctl stop firewalld
 ```
 4.禁用SElinux
 
    # 永久禁用SELinux方法一：
    vim /etc/sysconfig/selinux
    SELINUX=disabled

    # 永久禁用SELinux方法二:
    sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

    # 临时禁用, 让容器可以读取主机文件系统
    setenforce 0

4. 关闭系统SWAP
```bash
swapoff -a
```

5. 配置内核参数，将桥接的IPv4流量传递到iptables的链
```bash
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system
```
7. [配置docker国内镜像加速](docker国内镜像加速配置.md)
8. [配置k8s国内镜像加速](k8s国内镜像加速.md)
9. 升级内核
```bash
# 升级系统内核为 4.44
#CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定，例如 rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# 安装完成后检查 /boot/grub2/grub.cfg 中对应内核 menuentry 中是否包含 initrd16 配置，如果没有，再安装一次！

yum --enablerepo=elrepo-kernel install -y kernel-lt

# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.4.202-1.el7.elrepo.x86_64) 7 (Core)'

# 重启
reboot

# 检查是否安装新内核成功
uname -r
# 注意，内核会随着时间升级的，我写这篇文章的时候，内核版本是 4.4.202 ，这并不意味着你做的时候还是这个内核版本，如果变动了，请自行修改上面的命令即可。
```

10. yum 安装
```bash
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64   Kubernetes源设为阿里

# gpgcheck=0：表示对从这个源下载的rpm包不进行校验

# repo_gpgcheck=0：某些安全性配置文件会在 /etc/yum.conf 内全面启用 repo_gpgcheck，以便能检验软件库的中继数据的加密签署

# 如果gpgcheck设为1，会进行校验，就会报错如下，所以这里设为0

# repomd.xml signature could not be verified for kubernetes

```

### 二、 安装kubeadm、kubelet和kubectl
kubeadm不管kubelet和kubectl，所以我们安装kubeadm，还要安装kubelet和kubectl
- 查看kubelet版本 
```
yum list kubelet --showduplicates | sort -r
```
- 安装kubelet kubeadm kubectl
```bash
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Kubelet负责与其他节点集群通信，并进行本节点Pod和容器生命周期的管理。

# Kubeadm是Kubernetes的自动化部署工具，降低了部署难度，提高效率。

# Kubectl是Kubernetes集群管理工具。
```
- 启动kubelet
```bash
systemctl enable kubelet --now
```
以上k8s安装完成
### 三、 master安装部署

1. 开始初始化集群之前可以使用kubeadm config images list查看一下初始化需要哪些镜像
```bash
kubeadm config images list

#以下是初始化所需docker镜像

k8s.gcr.io/kube-apiserver:v1.16.0
k8s.gcr.io/kube-controller-manager:v1.16.0
k8s.gcr.io/kube-scheduler:v1.16.0
k8s.gcr.io/kube-proxy:v1.16.0
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.15-0
k8s.gcr.io/coredns:1.6.2

可以先通过kubeadm config images pull手动在各个节点上拉取所k8s需要的docker镜像，master节点初始化或者node节点加入集群时，会用到这些镜像

如果不先执行kubeadm config images pull拉取镜像，其实在master节点执行kubeadm init 或者node节点执行 kubeadm join命令时，也会先拉取镜像

本人没有提前拉取镜像，都是在master节点kubeadm init 和node节点 kubeadm join时，自动拉的镜像
# 拉取镜像
kubeadm config images pull
```

2. 初始化kubeadm
```bash
kubeadm init \
--apiserver-advertise-address=master机器的ip \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.16.0 \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16


# -–kubernetes-version: 用于指定k8s版本；
# -–apiserver-advertise-address：用于指定kube-apiserver监听的ip地址,就是 master本机IP地址。
# -–pod-network-cidr：用于指定Pod的网络范围； 10.244.0.0/16
# -–service-cidr：用于指定SVC的网络范围；
# -–image-repository: 指定阿里云镜像仓库地址

这一步很关键，由于kubeadm 默认从官网k8s.grc.io下载所需镜像，国内无法访问，因此需要通过–image-repository指定阿里云镜像仓库地址

```

3. 初始化成功
```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.128:6443 --token 4m0h7z.3r4sm23mzj60hvfv \
        --discovery-token-ca-cert-hash sha256:41dcf0d6627d2dd55fdb1843b3dd506aa0fb89d47657b81ece374ada1ccd6ce5
```
4. 按提示执行
```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config 
```
5. 将pod网络部署到集群
   - 下载kube-flannel.yml文件
   ```bash 
   curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```
   - 创建集群
   ```bash
   kubectl apply -f ./kube-flannel.yml
   ```
   - 查看node状态
   ```bash
   # 执行完后，查看node状态、pod状态
   kubectl get nodes
   ```
   - 查看pod状态
   ```bash
   kubectl get pod -n kube-system
   ```
   - 注意：master节点和node节点，都必须有这个镜像quay.io/coreos/flannel:v0.11.0-amd64

### 四、 node安装部署
- 首先确保node节点是否存在flannel的docker镜像
- 执行kubeadm join命令加入集群
  ```bash
   kubeadm join {masterIP}:6443 --token ep9bne.6at6gds2o05dgutd \
   --discovery-token-ca-cert-hash sha256:b2f75a6e5a49e66e467392d7d237548664ba8a28aafe98bdb18a7dd63ecc4aa8
   ```
- 到master节点查看node状态，都显示ready
   ```bash
   kubectl get node
   ```
- 移除Node节点
  - 在所以移除的node上执行
    ```bash
      kubeadm reset
    ```
  - 在master上移除node
     - 撤销kubeadm join，再手动rm掉提示的配置文件夹

     在master节点执行（kubectl get node可以查看节点名）   
     ```
     kubectl delete node 节点名称
     ```
### 五、 其它
- 创建pod 验证集群是否正常
   ```bash
   kubectl create deployment nginx --image=nginx

   kubectl expose deployment nginx --port=80 --type=NodePort

   kubectl get pod,svc
   ```
  
### 参考：https://blog.csdn.net/fuck487/article/details/101831415