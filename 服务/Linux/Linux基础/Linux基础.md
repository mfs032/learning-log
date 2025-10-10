# free输出的内存分类

```
root@S202507114370:~# free -h
               total        used        free      shared     buff/cache   available
Mem:            62Gi       1.7Gi        28Gi        21Gi        32Gi        39Gi
Swap:          8.0Gi       168Mi       7.8Gi

total：物理内存总量
used：total - free - buff/cache(正在被进程使用的共享内存)
free：完全未被使用的内存

shared：被使用的共享内存的总和。
有shared比used大的原因是临时文件系统(tmpfs)，在这个fs中存储的文件可以被进程共享访问。在tmpfs存储的文件没有进程在访问，used不会统计这个文件占用的内存，shared会统计被这个文件占用的内存。所以会出现shared比used大的情况。

buff/cache：内核缓存(块设备缓存+文件系统缓存)
buff块设备缓冲：内存写入磁盘的缓冲区
cache文件系统缓存：磁盘写入内存系统的缓冲区

available：系统可以立刻分配给新进程的内存


Swap交换空间：Linux的虚拟内存机制，使用磁盘空间来扩展可用内存容量，当物理内存不足时，系统将不活跃的内存页移动到Swap空间，从而释放物理内存给其他进程使用
free -h的Swap的三列分别是总Swap空间，已用Swap空间，空闲Swap空间
处理free -h还可以使用swapon查看

将内存数据从RAM上转移到硬盘上的交换空间，这个过程称为换出(swapping out)
操作系统将数据从交换空间读会RAM，这个过程称为换入(swapping in)
```

# tempfs

```
基于内存的临时文件系统。
该文件系统的所有文件会被存储到内存(RAM)中
1.内存存储：数据完全存储在内存中，读写速度极快（比传统磁盘快100倍以上）
2.临时性：系统重启后所有数据自动消失
3.动态大小：实际占用空间随内容变化，不超过设定的上限
4.可选交换支持：当内存不足时，可将部分数据交换到磁盘swap空间

临时创建挂载tmpfs
] mkdir /mnt/fast_temp
] mount -t tmpfs -o size=2G tmpfs /mnt/fsat_temp
] df -h /mnt/fast_temp
-t tmpfs指定文件系统类型tmpfs
-o size=2G指定tmpfs大小，如果不指定，默认占用物理内存的一半
tmpfs 文件系统设备名称，对于tmpfs就是tmpfs

永久挂载
] echo "tmpfs /mnt/fast_temp tmpfs defaults,size=2G 0 0" >> /etc/fstab
重启生效

```



# profile

```

```



# logrotate日志轮转

```
可以对日志进行压缩、归档、移动和删除
```

## logrotate工作原理

```shell
logrotate核心是一个配置文件。logrotate每天作cron任务执行一次。当logrotate运行时，会读取配置文件并根据文件中定义的规则对指定的日志文件执行操作。

logrotate配置文件
1. 主配置文件：/etc/logrotate.conf
	这个文件包含全局设置，例如轮转周期，日志压缩方式
2. 服务配置文件：/etc/logrotate.d/目录
	这个目录包含了针对特定应用程序的独立配置文件

配置nginx的logrotate日志轮转
cat <<EOF > /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 5
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi \
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endscript
}
EOF

#prerotate脚本判断一个文件是不是文件夹，是就运行这个文件夹中的所有脚本
#postrotate脚本想nginx发送rotate信号(即USR1)
```

## logrotate配置文件中各个选项的参数和作用

```
路径：/var/log/nginx/*.log
指要轮转的日志文件的完整路径。可使用通配符

周期：
	daily：每天轮转
	weekly
	monthly：
	yearly：
	size 10M：当日志文件达到指定大小（例如10MB）时，立即进行轮转。
	
保留份数：rotate 7
指定保留的归档日志文件数量。当达到这个数量时，最旧的归档文件会被删除

压缩：compress
轮转完成后将旧的日志文件进行压缩。默认gzip格式，文件扩展名.gz

延迟压缩：depaycompress
与compress一起使用。将压缩操作延迟到下一次轮转时使用。某些程序需要读取最新的轮转文件（例如前一天的日志）。

文件不存在时：missingok
如果指定的日志文件不存在，不报错并继续执行下一个任务

文件为空：notifempty
日志文件为空，不执行轮转操作

创建新文件：create <mode> <owner> <group>
在轮转旧文件后需要创建一个新的空日志文件，例如：create 0640 www-data adm，表示创建文件权限0640，所有者www-data，所属组adm

脚本钩子
prerotate
...
endscript：在日志轮转前执行的脚本
postrotate
...
endscript：在日志轮转之后执行的脚本

共享脚本：sharedscripts
不加这个选项，logrotate会在匹配到的所有日志文件轮转前后执行脚本钩子
加这个选项，logrotate会在匹配到的所有日志文件全部都轮转的前后执行脚本钩子
```



# 仓库

## yum仓库

```bash
ls /etc/yum.repos.d/

[repository-id]    # 库的唯一ID，不能包含空格
name=Repository Name  # 库的可读名称
baseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/  # 库的URL地址
        https://mirror2.example.com/centos/$releasever/BaseOS/$basearch/  # 支持多个URL（换行写）
# mirrorlist=http://mirrors.centos.org/mirrorlist?repo=baseos&arch=$basearch  # 或者使用镜像列表
enabled=1          # 是否启用该库 (1-启用, 0-禁用)
gpgcheck=1         # 是否进行GPG签名检查 (1-检查, 0-不检查)
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial  # GPG公钥的存放路径
priority=1         # 优先级（数字越小，优先级越高）。非必需项。
skip_if_unavailable=0 # 如果镜像不可用是否跳过 (1-跳过, 0-不跳过并报错)
```

## apt仓库

```bash
下载公钥
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /etc/apt/keyrings/nginx-archive-keyring.gpg

添加官方源
echo "deb [signed-by=/etc/apt/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
```





# fstab

```bash
临时扩大容量
mount -o remount在不中断服务的情况下，直接修改已挂载的tmpofs文件系统大小
mount -o remount,size=64g /var/cache/nginx/memory

永久挂载重启生效如下
```

## 文件内容

```bash
#/etc/fstab文件中每一行定义了一个需要挂载的文件系统，由六个字段组成

File System(文件系统):可以是硬盘分区(/dev/sda1)、UUID、LABEL(标签)、网络文件系统(nfs)或特殊文件系统(tmpfs)

Mount Point(挂载点)：定义挂载到哪个目录下，例如/、/home、/var/cache/nginx/memory，这个目录必须实现存在

Type(文件系统类型)：定义文件系统类型，常见有ext4、xfs、ntfs、swap、tmpfs、nfs

Options(挂载选项):定义挂载时的具体参数，多个选项之间用逗号分隔如default、ro(只读)、noatime(不更新文件访问时间)、size=64g(针对tmpfs)

Dump(备份选项)：定义是否允许dump工具进行备份。1表示允许备份，0表示不备份对大多数文件系统和特殊文件系统(tmpfs)通常设置为0

Pass(文件系统检查顺序)：定义系统启动时与逆行fsck(文件系统检查)的顺序0，1，2
	1：根文件系统(/)，系统第一个检查
	2：其他文件系统，按顺序检查
	0：不对该文件系统进行检查(例如tmpfs或网络文件系统)
```

```bash
#挂载选项
default选项
rw:
suid:允许set-user-ID和set-group-ID特殊权限位生效
dev:允许该文件系统上创建或使用字符设备或块设备
exec:允许执行该文件系统上的可执行程序
auto:
nouser:非用户，只允许root用户或者有sudo权限的用户挂载/卸载文件系统
async:异步写入，文件系统的操作是非同步的，数据写入缓冲区后操作系统立即返回写入完成，而不是等待数据真正写入物理设备

1.核心与通用选项
defaults:默认的通用选项集合，等于rw,suid,dev,exec,auto,nouser,async
rw:读写
ro:只读
auto:自动挂载，允许系统在启动时自动挂载
noauto:手动挂载，禁止系统在启动时自动挂载，必须手动执行mount命令

2.性能与寿命优化选项(针对磁盘)
noatime:不更新访问时间
nodiratime:不更新目录访问时间
relatime:相对时间。只有在文件被修改时(mtime变化)或上次访问超过一定时间后，才更新访问时间
noatime,nodiratime:完全停止记录文件和目录的访问时间，是tmpfs缓存目录的推荐设置，消除不必要的内存写入操作

3.tmpfs专用选项(内存文件系统)
size=xg:设置tmpfs的最大容量
nr_inodes=y:限制文件节点(inode)的最大数量。默认值很大
mode=0755:设置挂载点目录的权限
uid=www-data:设置属主
gid=www-data:设置属组
```

## 例子

```bash
#内存文件系统
echo "tmpfs /var/cache/nginx/memory tmpfs defaults,noatime,nodiratime,size=64g,uid=www-data,gid=www-data 0 0" >> /etc/fstab

#网络设备文件
echo "192.168.1.10:/data /mnt/nfs_backup nfs defaults,_netdev,hard,intr 0 0" >> /etc/fstab
#_netdev:关键资源，告诉系统这是一个网络设别，必须在网络服务启动之后再尝试挂载
#hard:可靠性，如果远程服务器无响应，NFS客户端会无限期重试，知道请求完成
#intr:可用性，允许中断硬挂载(hard)的重试操作

#块设备(ext4)
#挂载传统硬盘分区到/home目录
echo "UUID=xxxxx-xxxxx-xxxx-.... /home ext4 defaults,relatime 1 2"
```



