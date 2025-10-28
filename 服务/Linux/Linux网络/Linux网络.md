# nmcli

```bash
nmcli [options] object command [arguments]
###
general(g):报告NetworkManager服务的整体状态
networking(n):控制NetworkManager的开关
device(d):查看和管理硬件网卡设备(如ens160)
connection(c):管理网络连接配置文件
```

## 常用对象和命令

```bash
1.nmcli general(服务状态)
用于检查NetworkManager服务的整体状态
nmcli general status	#检查networkManager的运行状态、连接状态和网络连接性
###
[root@localhost ~]# nmcli g status
STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN     METERED 
connected  full          missing  enabled  missing  enabled  no(guessed) 
STATE: connected：表示 NetworkManager 已成功建立网络连接
CONNECTIVITY: full：说明网络连接状态完整，能够正常访问互联网和局域网。
###

nmcli general hostname	#显示或修改主机名
###
[root@localhost ~]# cat /etc/hostname

[root@localhost ~]# nmcli g hostname

[root@localhost ~]# 
###
```

```bash
2.nmcli device(网卡设备管理)
device设备就是实际存在的网络硬件或虚拟网络接口
nmcli device status	#列出所有设备(网卡)及其状态
nmcli device show <设备名>	#显示设备的详细信息、ip地址等
nmcli device disconnect	#临时断开指定设备，但不删除配置
```

```bash
3.nmcli connection(连接配置文件管理)
connection连接，是NetworkManager定义的网络配置文件，即设备连接网络的规则。一个设备可以关联多个连接，一个连接只能绑定一个设备

#A.查看连接
nmcli con show	#列出所有已保存的网络连接配置
nmcli con show --active	#仅列出当前处于活动状态的连接
nmcli con show <连接名称> #显示特定连接配置文件的所有参数

#B.激活/停用连接
nmcli con up <连接名称>
nmcli con down <连接名称>

#C.创建新连接
nmcli con add #创建一个新的连接配置文件
nmcli con add type ethernet con-name static-eth0 ifname eth0
#type ethernet 连接类型为以太网
#con-name static-eth0 连接配置文件名称
#ifname eth0 绑定到eth0设备

#D.修改连接

```

