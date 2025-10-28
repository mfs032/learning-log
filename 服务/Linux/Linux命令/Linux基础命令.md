# 包管理器

## apt和dpkg

```shell
#升级软件包，生产环境不要用
apt upgrade	

#安装软件包
apt install 包名1 包名2

#卸载软件包
apt remove 包名	#卸载但保留配置文件
apt purge 包名	#卸载并删除配置文件

#搜索软件包
apt search 关键词	#搜索包含关键词的软件包
apt list	#列出所有可用的软件包
apt list --installed	#列出已安装的软件包

#缓存
apt update		#更新软件包索引
apt autoclean	#清理过时的缓存包
apt clean	#清理所有缓存包

#常用选项
-y
-q
```

```bash
dpkg [选项] [命令] [包名|.deb文件]
dpkg -i 包名.deb	#安装软件包

#卸载
dpkg -r 包名 #卸载保留配置文件
dpkg -p 包名	#完全卸载，删除配置文件

#查询包
dpkg -l	#列出所有包
dpkg -L 包名 #列出包安装的所有文件
dpkg -S /path/to/file	#查询文件属于哪个包
```





## yum和rpm

```bash
yum [选项] [命令] [包名]

#更新系统，生产环境不要用
yum update #更新所有已安装的软件包(包括内核)
yum upgrade	#类似update，但会删除旧包

#安装软件包
yum install 包名	#安装指定软件包
yum install 包名1 包名2	#同时安装多个包

#卸载软件包
yum remove 包名	#卸载指定软件包，保留配置文件
yum erase 包名	#卸载并删除相关配置文件

#搜索软件包
yum search 关键词	#搜索包含关键词的软件包
yum list	#列出所有可安装的软件包
yum list installed	#列出已安装的软件包
yum info 包名	#查看软件包的详细信息

#清理缓存
yum clean all	#清理所有缓存，包括下载的包
yum makecache	#重建缓存，加快搜索速度

#查看依赖关系
yum deplist 包名	#查看某个包的依赖关系

#常用选项
-y
-q	#静默模式，减少输出
--nogpgcheck	#跳过gpgcheck

#解决依赖冲突
yum provides */缺失的文件名	#查找哪个包提供缺失的文件
yum history	#查看操作历史
yum history undo 事务ID	#回滚某个安装操作
```

```bash
rpm [选项] [命令] [包名|rpm文件]

#安装rpm包
rpm -ivh 包名.rpm	#i=install，-v显示操作信息，-h显示安装进度条

#卸载rpm包
rpm -e 包名	#卸载，无需版本号

#查询rpm包
rpm -q 包名	#检查是否安装
rpm -qi 包名	#查看包的详细信息
rpm -ql 包名	#列出包安装的文件
rpm -qc 包名	#列出包的配置文件
rpm -qd 包名	#列出包的文档文件
rpm -qf /path/to/file	#查询某个文件属于哪个包
```





# grep命令

```bash
grep [选项] "搜索模式" [文件...]
若不指定文件：则从标准输入读取数据
搜索模式：可以是普通字符串或正则表达式
文件可以是单个，可以是通配符的多个，可以是文件夹(要制定-r/-R)

常用选项：
-i 忽略大小写 grep "error" log.txt
-v 反向匹配  grep -v "success" log.txt
-w 匹配完整单词(避免部分匹配) grep -w "port" config.conf
-n 显示匹配的行号 grep -n "warning" debug.log
-c 统计行号(不显示内容)  grep -c "404" access.log
-q 静默模式，匹配成功失败不输出

文件处理
-r/-R 递归搜索目录下的文件 grep -r "main()" /src/
--include 指定文件类型(通配符) grep -r --include="*.py" "import" ./
--exclude 排除特定文件  grep -r --exclude="*.tmp" "*.py" /logs/
-l 只显示包含匹配项的文件名	 grep -l "TOOD" *.md
-L 显示不包含匹配项的文件名	grep -L "passwd" *.conf

控制输出
-A num	显示匹配行以及后num行	grep -A 2 "Exception" trace.log
-B num	显示匹配行及前num行		grep -B 3 "segmentation fault" crash..log
-C num  显示匹配行前后各num行	grep -C 1 "critical" system.log
--color=auto	高亮匹配文本(默认启用)	grep --color "ERROR" app.log

正则表达式
-E	启用扩展正则(等同egrep)  grep -E "^[:space:]*#|^$" /etc/nginx/nginx.conf
-P	启用Perl正则	grep -P “\d{3}-\d{4}” phones.txt
-F	禁用正则		grep -F "*.txt" files.list


grep -vE "^[[:space:]]*#|^$" nginx.conf
```

## `-f`选项

```bash
grep -f 模式文件 目标文件
模式文件（pattern file）：包含一个或多个匹配模式的文件，每行一个模式（支持正则表达式），这个正则取决于grep的选项，默认基础正则,如果使用-E则是扩展正则
目标文件：需要搜索的文件（或通过管道传递的内容）。


模式文件 patterns.txt（每行一个关键词）：
error
warning
critical
目标文件 app.log（需要搜索的日志）：
2023-10-01 08:00 info: system started
2023-10-01 08:05 warning: low memory
2023-10-01 08:10 error: connection failed
2023-10-01 08:15 info: retry connection
2023-10-01 08:20 critical: disk full
] grep -f patterns.txt app.log

例如 patterns.txt 内容为：
^2023-10-01 08:0[0-5]  # 匹配 08:00-08:05 之间的日志
error|critical          # 匹配包含 error 或 critical 的行

] grep -E -f patterns.txt app.log  # -E 启用扩展正则表达式
加上 -v 选项，可排除所有匹配模式的行：
] grep -v -f patterns.txt app.log
```



# cat命令

```
-A参数显示所有不可见字符
^M表示\r,win换行符
$表示行最后一个非\n字符和\n之间的位置,
^I表示\t，制表符
```



# mkdir

```
-p 使用mkdir创建文件夹，如果文件夹存在会报错。使用-p选项，如果文件夹存在不报错
```



# curl命令

```
curl通过URL传输数据，支持多种协议(HTTP、HTTPS、FTP等)，可用于测试API、下载文件或与服务器交互

基本用法：
发送get请求，默认发送get请求，返回服务器响应内容
curl http://example.com

保存输出到文件，小写自定义文件名，大写使用远程文件名
curl -o output.html http://example.com
curl -O http://example.com
```

## 常用选项

```
-X [METHOD]  指定请求方法(GET POST PUT)
-H "Header: value"  添加请求头(如 -H "content-type: application/json")

-d "data"  发送请求体数据(用于POST/PUT)
-i			显示响应头+响应体
-I			只获取响应头，不下载响应体
-v 			显示详细调试信息(包括请求头和请求体)
-u user:pass	基本认证(-u admin:12345)
-L			自动跟随重定向
```

## 用法

### 下载文件

```
# 1. 下载文件并保留服务器上的原文件名
# 示例：下载 Python 3.11 安装包，保存为 "python-3.11.4-amd64.exe"
curl -O https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe

# 2. 自定义下载后的文件名
# 示例：将上述安装包保存为 "py311.exe"
curl -o py311.exe https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe

# 3. 断点续传（适合大文件，中断后无需重新下载）
# 示例：继续下载中断的大型 ISO 文件
curl -C - -O https://example.com/large-system.iso
# 说明：-C - 表示“从上次中断的位置继续”，需确保文件名和之前一致
```

```shell
-f: 这个选项代表 --fail。它的作用是让 curl 在 HTTP 请求失败时（例如遇到 404 Not Found 或 500 Internal Server Error）以静默模式退出，而不会在标准输出中显示错误信息。这有助于在脚本中进行错误处理。

-s: 这个选项代表 --silent。它会使 curl 进入静默模式，不显示进度条或错误信息，让输出更干净。

-S: 这个选项代表 --show-error。它通常与 -s 选项一起使用，当出现错误时，虽然不显示进度条，但会显示错误信息。

-L: 这个选项代表 --location。如果请求的 URL 发生了重定向，curl 会自动跟随重定向，直到找到最终的资源。

Ubuntu下载公钥
curl -fsSL https://repo.zabbix.com/zabbix-official-repo.key | sudo gpg --dearmor -o /etc/apt/keyrings/zabbix-archive-keyring.gpg
```







# ulimit

```
ulimit -a可以看到所有限制值
ulimit -n看最大文件描述符数

单个进程最大连接数在/etc/security/limits.conf里修改
* soft nofile 65536
* hard nofile 65536


临时修改
sudo su # 切换到 root 用户
ulimit -Hn 1048576		修改硬上限
ulimit -Sn 65536 	修改硬上限
ulimit -n 65536	两个同时设置
```







# tee命令

```shell
输入输出类似T
需要一个输入
会有两个输出，一个到命令行，一个到指定的输出文件

] echo "Hello World" | tee file.txt
] ls | tee fiel.txt
默认覆盖
-a选项append表示追加
] ls | tee -a file.txt

抑制终端输出
] ls | tee -a file.txt > /dev/null
```

# 标准输入、标准输出、命令行参数

```
在Linux系统中一切皆文件，每一个文件都有一个标识符叫文件描述符
系统默认给每一个进程自动创建三个标准文件描述符：
文件描述符0：标准输入(stdin)
文件描述符1：标准输出(stdout)
文件描述符2：标准错误(stderr)
当一个命令启动时，标准输入的文件描述符0默认指向键盘，也就是从键盘读取数据
但是当使用|或者<这个文件描述符0的指向会变
管道符|：
command1 | command2
管道符会将command1的文件描述符1和command2的文件描述符0连起来
重定向<:
command < file.txt
文件描述符会重定向到文件file.txt



一些命令可以在结尾加上文件名参数，告诉这个命令要操作的文件是哪一个。
如果这些命令不加文件名参数，会切换到从标准输入读取数据
例如 ] grep "h" file.txt
	] echo "hello" | grep "h"
	
标准输入和命令行参数是两个不同的东西：
命令行参数是跟在命令后面的参数，一般作为字符串传递给命令解析
标准输入(stin)是通过管道符| 或输入重定向<传递给命令的

例如rm零零，rm命令要加上文件名参数，告诉这个命令要操作哪个文件
find / -name "*,bak"这个find命令输出的是一个列表的形式输出到标准输出:
/1.bak
/2.bak
如果直接使用|将find的标准输出和rm的标准输入连起来没用，rm命令不从标准输入读取数据

例如grep "com" domains.txt
和grep "com" < domains.txt输出的内容是一样的，但是grep读取数据的方式不同
作为命令行参数grep会调用系统函数open()打开文件逐行读取数据
第二个grep是从标准输入读取数据
```



# find命令

```bash
find [搜索路径] [匹配条件] [操作]
搜索路径：指定查找的目录（默认是当前目录 .）
匹配条件：按文件名、类型、时间、权限等筛选文件
操作：对匹配的文件执行的操作（如删除、打印等）

#常用匹配条件
#1.按文件名查找
find /path -name "*.txt"	#查找/path下左右.txt文件
find /path -iname "*.TXT"	#忽略大小写
find /path -regex ".*\.log$"	#使用正则匹配

#2.按文件类型查找
find /path -type f	#查找普通文件
find /path -type d	#查找目录
find /path -type l #查找符号链接
find /path -type s	#查找套接字文件

#3.按照大小查找
find /path -size +10M	#查找大于10MB的文件
find /path -size -1G	#查找小于1GB的文件
b(512字节块c(字节)k(KB)M(MB)G(GB)

#4.按时间查找，m修改，a访问
find /path -mtime +7	#查找7*24小时之前修改的文件，-7就是之内的文件
find /path -amin -7		#查找7分钟之内被访问的文件


#执行操作
#建议使用|和xargs和其他命令拼接进行操作，不推荐-exec
find /path -name "*.log" -exec rm {} \;  # 删除所有 `.log` 文件
{}表示匹配的文件名。
\;表示命令结束（必须转义）。
```





# xargs命令

```
一些命令只能从命令行读取参数，无法读取标准输入的数据

需要一个中间件xargs，xargs设计为只能从标准输入读取数据，将标准输出里的数据通过管道|给xargs的标准输入，xargs解析转换成命令行参数床底给rm

find / -name "*.bak" | xargs rm -rf
|将find命令的标准输入重定向到xargs的标准输入中
xargs会从标准输入读取数据，进行解析，并和xargs的参数构建成一个新的命令rm -ef /1.bak /2.bak
```

```bash
xargs默认以 空格/换行符 分隔输入，并将每行作为参数传递给目标命令：
echo "file1 file2 file3" | xargs rm
# 相当于执行：rm file1 file2 file3

默认情况下，xargs将参数追加到命令末尾。使用 -I可以指定参数位置：
find . -name "*.txt" | xargs -I {} mv {} /backup/
# 相当于：mv file1.txt /backup/; mv file2.txt /backup/ ...

find / -name "*.txt" -type f -print0 | while IFS='' -r -d '' file; do
	file_name=${file##*/}
	mv ./$file_name ./backup/$file_name
done
```





# Here Document

```shell
<和<<都是用来输入重定向的，
<是将文件的内容重定向到命令的标准输入
<<符号也叫Here document,将一个内联的文本块重定向到命令的标准输入
<<的语法：
命令 << 分隔符 内容 分隔符


允许你将多行文本作为命令的标准输入，而不需要从文件中读取。

<< 是输入重定向，它将一段文本（称为 "Here Document"）作为命令的输入。
] cat <<EOF > file.txt
asdfasfa
asfasdaw
EOF

] cat <<'EOF' | xargs rm -rf
1.bak
2.bak
EOF


如果输入的文本中有$变量的引用，要使用''包裹EOF，结尾不需要包裹
] cat <<'EOF' > file.txt
aaa
EOF


] grep "apple" <<EOF > file.txt
ascfsa
asdw
EOF


] wc -l <<EOF
ascas
csasc
EOF

] cat <<EOF | tee file.txt
aaa
EOF

] tee file.txt <<EOF
aaa
aaa
EOF


```



# tar命令

```shell
打包
] tar -zcvf file.tar.gz file.txt

解包
] tar -xvf file.tar.gz -C /tmp
-C指定解压目标文件夹
--strip-components=N指定要删除的父目录，N表示删除几级
] tar -xvf file.tar.gz --strip-components=4 -C /tmp
```





# history命令

```shell
按下Ctrl + R会进入反向匹配history中地命令
此时输入命令，会匹配history中符合地最近地一条指令
再次按下Ctrl + R会匹配第二近地一条指令
```



# du命令

```shell
统计文件或者文件夹占用的磁盘块数量，然后将数量转化为大小
-h：人类可读
-s：summarize总计大小

#统计指定目录总大小
] du -sh .
] du -sh /var/log/www/

```

# sort命令

对文本内容或标准输入的内容进行排序，默认按照字典升序从小到大

```shell
-r：reverse降序，从大到小

-n：numeric按照数值大小排序

-k：key指定排序的列，sort默认使用空格或制表符作分割,例如sort -k 2

-t：指定分隔符，例如指定,做分隔符sort -t','

-u：去除重复的行，只显示唯一的行

```





# rm命令

```shell
rm命令实际上只是解除了文件系统中的文件路径和文件 inode（索引节点）之间的链接。

每个文件都有一个或多个指向它的硬链接。当你用 ls -l 命令查看文件时，第二列的数字就代表硬链接的数量。当你删除一个文件时，你实际上只是将它的硬链接计数减一。

如果硬链接计数减到 0：这意味着没有任何文件名指向这个文件了。此时，操作系统会将该文件标记为“已删除”，但并不会立即从磁盘上清除数据。只有当最后一个使用该文件的进程关闭后，inode 和磁盘空间才会被真正释放，供其他文件使用。

如果硬链接计数大于 0：这意味着还有其他文件名指向该文件（比如你通过 ln 命令创建了硬链接）。在这种情况下，删除操作不会有任何影响，文件仍然存在，只是你删除的那个文件名找不到了。


正在被打开的文件
当一个文件被进程打开时，这个进程会保持一个对文件 inode 的引用。这意味着即使你删除了文件路径，该文件在磁盘上的数据和 inode 仍然存在，直到这个进程关闭。

这意味着什么？

文件路径消失：你无法再通过原来的文件名访问这个文件。例如，ls 命令会显示文件不存在。

进程可以继续读写：正在使用这个文件的进程不受影响。它可以继续读写文件内容，直到它自己关闭文件句柄。

磁盘空间不释放：文件占用的磁盘空间直到进程关闭后才会被释放。这就是为什么有时你删除一个大日志文件，但磁盘空间没有立即增加的原因。

实际应用举例
一个常见的例子是服务器上正在写入的大型日志文件。如果你发现 /var/log 目录下的某个日志文件过大，你可能会使用 rm 命令删除它。

错误操作：rm /var/log/app.log。文件路径被删除，但日志服务（如 rsyslogd 或 fluentd）还在继续写入这个文件，导致磁盘空间没有立即释放，反而看起来像一个“幽灵”文件。

正确操作：应该先停止日志服务，删除文件，再重新启动服务。或者，更常见的做法是使用重定向命令清空文件内容，而不是删除它：
> /var/log/app.log 或 echo "" > /var/log/app.log。
这样可以保留文件句柄和 inode，文件内容被清空，磁盘空间立即释放，而进程可以继续正常写入。
```



# lsof命令

```shell
lsof：list open files打开正在被使用的文件

lsof | grep "deleted"可以看到已删除，但是正在被使用的文件以及对应的进程id，杀死这个进程就行
```



# ps命令

```bash
-e:显示系统上的所有进程，等效-A，没有这个选项只显示与当前终端(TTY)相关的进程。
-f：显示完整的格式，提供更多的信息
UID	启动该进程的用户ID（通常是用户名）
PID	进程ID
PPID	父进程ID
C	CPU 使用率
STIME	进程启动时间
TTY	进程所在的终端
TIME	进程消耗的总CPU时间
CMD	完整的命令行（包括启动路径和参数）

```



# top命令

```bash
top输出主要有两个部分：概况区和进程区
##1.概况区
#第一行：时间、运行时间、负载平均值
top - 01:27:42	当前时间
up 10 days, 2:35 系统运行时间
1 user			当前登录用户数
load average: 0.00, 0.01, 0.05	系统平均负载：过去1分钟、5分钟、15分钟，等待CPU资源的进程数
例子：
top - 06:37:43 up 12 days, 25 min,  2 users,  load average: 0.14, 0.07, 0.02

#第二行：任务/进程
Tasks: 180 total	系统中的总进程数
1 running			正在运行(使用CPU)的进程数
175 sleeping		正在休眠(等待I/O或事件)的进程数
4 stopped			已停止但尚未终止的进程数
0 zombie			僵尸进程数(Zombie Processes)已完成但父进程尚未清理的进程。非零值通常是程序错误的信号
例子：
Tasks: 106 total,   1 running, 105 sleeping,   0 stopped,   0 zombie

#第三行：CPU状态
us	用户空间(User Space)	用户进程在CPU上花费的时间百分比。
sy	内核空间(System Space)	内核代码在CPU上花费的时间百分比(如系统调用)
ni	Nice值	带有非默认nice值的用户进程所占用的CPU百分比
id	空闲(Idle)	CPU处于空闲状态的百分比。
wa	I/O等待		CPU在等待磁盘I/O完成时花费的时间百分比
hi	硬件中断(Hardware IRQ)	处理硬件中断的时间
si	软件终端(Software IRQ)	处理软件中断的时间
st	偷取时间(Steal Time)	仅在虚拟机可见，标识被同一物理主机上其他VM偷走的CPU时间
例子：
%Cpu(s):  3.2 us,  0.0 sy,  0.0 ni, 96.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st

#第四、五行：内存状态
Mem	total	物理内存总量
Mem	free	闲置的物理内存量
Mem	used	已使用的物理内存量
Mem	buff/cache	用作缓冲区和缓存的内存量
Swap	total/free/used	交换分区的总量、空闲量和已使用量
例子：
MiB Mem :   3913.3 total,   2676.3 free,    265.6 used,    971.3 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3419.8 avail Mem

##2.进程区
列名,含义
PID,进程 ID (Process ID)，用于识别进程
USER,运行该进程的用户
PR,优先级 (Priority) — 内核调度优先级
NI,Nice 值 (Nice Value) — 进程的友好值，范围 -20 (高优先级) 到 19 (低优先级)
VIRT,虚拟内存 (Virtual Memory) — 进程使用的总虚拟内存
RES,驻留内存 (Resident Memory) — 进程在物理内存中占用的实际内存量 (重要)
SHR,共享内存 (Shared Memory) — 进程可以与其他进程共享的内存量
S,"进程状态 (State) — 如 R (Running), S (Sleeping), Z (Zombie) 等"
%CPU,进程上次更新以来占用的 CPU 百分比 (默认排序依据)
%MEM,进程在物理内存中占用的 内存百分比
TIME+,进程自启动以来占用的 CPU 总时间 (精确到百分之一秒)
COMMAND,启动进程的命令行名称
```

## top交互式操作

```bash
h或?		显示帮助信息
k		杀死(kill)进程，按下后输入PID，然后选择信号
r		重置Nice值
P(大写)	按CPU使用率排序
M(大写)	按内存使用率排序
T		按运行时间排序
1		切换CPU显示模式，显示所有CPU
z(小写)	切换彩色显示模式
W	将当前的配置(排序、字段)写入配置文件，下次启动top使用此配置
q	推出top命令
```

## top命令的常用启动参数

```bash
-d	刷新时间，单位秒 top -d 1.5
-p	监控指定的PID进程top -p 1234
-u	监控指定用户运行的进程top -u www
-n	刷新N次后自动退出，top -n 1脚本自动采集数据
-b	一批处理模式运行，并将结果输出到文件或管道中top -b -n 1
```









# journalctl命令



