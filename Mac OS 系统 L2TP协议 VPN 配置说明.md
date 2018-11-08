# Mac OS 系统 L2TP协议 VPN 配置说明

### No.1 添加L2TP协议支持

```
$ sudo vim /etc/ppp/options
#复制以下内容到文本内
plugin L2TP.ppp
l2tpnoipsec

# 退出vim
:wq
```

### No.2 配置VPN 用户名密码码

- 打开“系统偏好设置”->“网络”->左测例表中点击“+”号->接口选择“VNP”->VPN类型选择“L2TP/IPSec“
- 配置自己VPN信息