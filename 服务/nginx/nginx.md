# nginx的配置文件

```
nginx的配置文件：
conf.d/
fastcgi.conf
fastcgi_params
koi-utf
koi-win
mime.types
modules-available/
modules-enabled/
nginx.conf
proxy_params
scgi_params
sites-available/
sites-enabled/
snippets/
uwsgi_params
win-utf
```

## nginx.conf配置文件各个部分

配置文件由不同的块(Block)组成。这些块也称为上下文(Contexts)



### main Context全局上下文

，位于最外层，配置影响nginx全局的参数，如工作进程、连接超时等。

```shell
1. 定义全局配置：
	user nginx;：指定nginx工作进程的用户和组，关系到文件权限
	worker_processes auto;:定义nginx启动多少个工作进程，通常设置为CPU的核心数或auto
	error_log /var/log/nginx/error.log warn;：错误日志路径和记录级别(debug info warn error)
	pid /run/nginx.pid;:nginx主进程的pid文件
	
2. 包含其他配置文件
	使用include来加载其他目录下的配置文件
	include /etc/nginx/modules-enabled/*.conf;
	include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
    
3. 顶级块
在主配置文件中有几个顶级块，各有不同用处
	events{}：定义服务器的连接处理机制，影响性能
	http{}：处理HTTP/HTTPS请求，包括Web页面，API和文件服务
	mail{}：处理邮件协议(IMAP，POP3，SMTP)
	stream{}：处理TCP/UDP流量，用于非Web协议的代理和负载均衡
```

例子

```nginx
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
```



### Events Context事件上下文

控制nginx处理连接的网络事件模型，例如，worker_connection 1024定义每个工作进程可以同时处理的最大连接数

```
	worker_connections 1024;：单个工作进程的最大并发连接数
	use epoll;：指定事件的驱动模型
	multi_accept on;：允许一个进程同时接受多个新连接
	accept_mutex off;：是否启用连接互斥锁(高并发建议关闭)
```

例子

```nginx
events{
    worker_connections 1024;
    use epoll;
    multi_accept on;
    accept_mutex off;
}
```



### HTTP Context HTTP上下文

所有HTTP相关的配置(HTTP/HTTPS服务器、代理、缓存等)

```
基础：
	include mime.types;：引入MIME类型文件
	default_type text/plain;：默认响应Content-Type
	log_format main '$remote_addr - $request';：定义访问日志格式
	access_log /var/log/nginx/access.log main;：定义访问日志的路径和格式

性能：
	sendfile on;：启用高效文件传输
	tcp_nopush;：优化数据包发送(需sendfile on)
	keepalive_timeout 65s;：客户端保持连接的超时时间

压缩：
	gzip on;：启用Gzip压缩
	gzip_types text/css application/json;：指定压缩的文件类型
	
SSL：
	ssl_protocols TLSv1.2 TLSv1.3;：允许的SSL/TLS协议版本
	ssl_ciphers HIGH:!aNULL:!MD5;：加密算法套件
```

例子

```nginx
http{
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request"';
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    
    gzip on;
    gzip_types text/plain text/css application/json;
    
    include /etc/nginx/conf.d/*.conf
}
```

### Server Context服务器上下文

定义一个虚拟主机

```
监听：
	listen 80;或listen 443;：监听的端口
	server_name www.example.com;：匹配的域名

路径：
	root /var/www/html;：站点根目录
	index index.html index.php;：默认索引文件
	
SSL：
	ssl_certificate /path/to/cert.pem;：SSL证书路径
	ssl_certificate_key /path/to/key.pem;：SSL私钥路径
	
重定向：
	return 301 https://$host$request_uri;：重定向(如HTTP -> HTTPS)
	
错误页：
	error_page 404;：自定义错误页面
```

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    error_page 404 /404.html;
    location = /404.html {
        internal;
    }
}
```

### Location Context 位置上下文

根据URI匹配特定规则

```
匹配规则：
	location /images/ {...}：匹配前缀
	location ~ \.php$ {...}：匹配后缀

文件处理：
	try_files $uri $uri/ /index.php;：按顺序尝试查
找资源
	alias /data/images/;：替换匹配的路径前缀

代理：
	proxy_pass http://backend;：转发请求到后端服务器
	proxy_set_header Hos $host;：修改转发请求头

缓存:
	expires 30d;：静态资浏览器缓存时间
	
访问控制：
	allow 192.168.1.0/24; deny all;：IP黑白名单
```

例子

```nginx
location /static/ {
    alias /data/static/;
    expires 365d;
    access_log off;
}

location ~ \.php$ {
    fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}

location /damin/ {
    allow 192.168.1.100;
    deny all;
    proxy_pass http://localhost:8080;
}
```

### Upstream Context上游上下文

定义一组后端服务器，用于负载均衡或代理

```
	server 10.0.0.1:80 weight 5;：后端服务器的地址和权重
	least_conn;：使用最少连接数策略
	ip_hash;：基于客户端IP的会话保持
	keepalive 32;：到后端的持久连接数
```

例子

```nginx
upstream backend {
    least_conn;
    server 10.0.0.1:80 max_fails=3 fail_timeout=30s;
    server 10.0.0.2:80 backup; #备用服务器
    keepalive 16;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

### Mail Context邮件上下文

配置邮件代理服务

```

```

### Stream Context流上下文

四层传输代理，用于非HTTP流量(如数据库、SSH等)。与HTTP属于同一类上下文

```nginx
Stream {
    upstream db {
        server 192.168.1.10:3306;
    }	
    
    server {
        listen 3306;
        proxy_pass db;
    }
}
```



## conf.d/

```shell
为了防止所有的配置都挤在一个庞大的nginx.conf文件里，conf.d目录就是解决方式的其中之一，实现配置文件的模块化
1. 模块化
	为每一个独立的配置任务创建一个单独的文件
	例如，ssl.conf用于存放SSL/TLS参数、log.conf存放日志相关的配置，比如自定义日志格式
	
2. 易于管理维护
	模块化的结构让配置管理变得非常高效
	添加配置：只需要在conf.d/中创建一个新文件
	删除或禁用配置：只需要删除对应文件或者重命名为非.conf后缀
	排查问题：如果是某个配置出了问题，可以快速定位到具体的文件

3.自动化友好
	自动化脚本可以简单的将一个特定的配置文件放入conf.d/文件夹中，而无需解析或修改主配置文件
```

## sites-available/和sites-enabled/

### sites-available/(可用站点)

```
该目录用于存放所有创建的、但尚未启用的虚拟主机配置文件。每一个文件对应一个独立的网站或域名

可以在这里创建、编辑、存储所有站点的配置文件，无论是否正在运行
```

### sites-enabled/(启用站点)

```
该目录被主配置文件include，用于存放当前正在运行的网站配置。通过软链接的方式，指向sites-available目录中的文件
```



## modules-available/和modules-enabled/

```
用于管理动态模块，类似sites，分离模块的安装和激活
```

### modules-available/(可用模块)

```
这个目录包含了所有已安装的Nginx的动态模块文件(.so文件)。

当通过包管理工具安装额外的Nginx模块会被放到这个目录中，这些模块是可用的，但nginx不会自动加载他们
```



### modules-enabled/(启用模块)

```
nginx的主配置文件默认include这个文件夹。
启用模块：这个目录中创建一个软链接，Nginx会在启动的时候加载该模块。
禁用模块：将模块对应的软链接从该文件夹中删除
```



## mime.types

```
Nginx 通过件扩展名映射和MIME类型检测来识别要发送的文件类型，并据此设置正确的 Content-Type响应头。

/etc/nginx/mime.types，定义了文件扩展名到MIME类型的映射表
types {
    text/html                             html htm shtml;
    text/css                              css;
    application/javascript                js;
    image/jpeg                            jpeg jpg;
    application/json                      json;
}

左边是要设置的响应头，右边是响应文件的扩展名
```



## snippets/

```shell
这个目录用来存放可重复的，小的配置代码片段，例如server块中的整个location块，或者location块中的一小段代码或参数
```





# nginx常用参数

### `-v`和`-V`

```shell
-v	Print the nginx version.
查看nginx的版本号

-V Print the nginx version, compiler version, and configure script parameters.
查看nginx的版本号，编译时所有的配置参数(安装的模块、编译选项、依赖库路径)

#可以拿来查看版本号或者已安装的模块
] nginx -V | grep ngx_http_stub_status_module
```

### `-t`

```bash
判断nginx配置文件有没有配置错误
] nginx -t
```





# 查看nginx并发情况

```shell
ngx_http_stub_status_module nginx的内置模块

在snippets/目录下添加配置文件
] vim /etc/nginx/snippets/nginx_status.conf

location /nginx_status{
	stub_status on;#打开nginx状态监控界面
	access_log off;#阻止nginx写入日志
	allow 127.0.0.1; #允许本地访问
	deny all; #拒绝所有其他IP访问
}

保存配置文件，并在需要的虚拟主机中通过include引用开启
] vim /etc/nginx/sites-avaiable/www.asdas.conf
server{
...
#通过include引用，结尾要加;
include /etc/nginx/snippets/nginx_status.conf;
}

] nginx -t
] systemctl reload nginx

访问该接口获得并发信息
] curl http://127.0.0.1:80/nginx_status
```



# Nginx优化

## 场景

```
1.高并发连接：当服务器需要处理成千上万的连接时(如WebSocket、实时通信、大流量网站)
2.高吞吐量需求：需要传输大量静态文件(如图片、视频、下载站)
3.CPU或内存资源耗尽:监控系统(如top、htop、vmstat)显示nginx工作进程占用了大量CPU或内存
4.响应时间变慢：用户或者监控工具报告网站响应速度变慢，而数据库本身并非瓶颈
5.SSL/TLS开销过大：HTTPS加密解密操作消耗大量CPU资源
6.系统打开文件数限制
```

## 优化维度与集体参数

Nginx的优化主要围绕四个核心资源：CPU、内存、网络i/O、磁盘I/O

### 维度1：工作进程与连接优化(CPU & Menory)

这部分优化主要在main和events上下文

```
worker_process auto;
	作用：工作进程数
	优化：设置为CPU核心数(grep processer /proc/cpuinfo | wc -l)或者auto
	
worker_connections 1024;
	作用：单个工作进程可处理的最大连接数
	优化：增大此值(如4096)已处理更多并发连接。最大客户端 = worker_processes * worker_connections
	
worker_rlimit_nofile 65536;
	作用：提高nginx进程可以打开的文件描述符(FD)限制
	优化：必须设置为至少worker_connections * 2。通常系统级也需要修改为ulimit -n
	
use epoll;
	作用：指定高效的事件驱动模型
	优化：Linux使用这个就对了
	
multi_accept on;
	作用：允许一个工作进程同时接受多个新连接
	优化：高并发时更有效
	
accept_mutex off;
	作用：关闭互斥锁，让工作进程轮流接受新连接
	优化：建议关闭，避免不必要的上下文切换，让内核更智能的分配连接
```

例子

```nginx
user www-data;
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
    accept_mutex off;
}
```



### 维度2：网络与数据传输优化(Network I/O)

这部分优化主要在http上下文

```
sendfile on;
	作用：启用零拷贝技术，文件数据直接从内核空间发送到网卡，无需经过用户空间
	优化：必须开启，传输静态文件效率极高

tcp_nopush on;
	作用：在sendfile on时有效，将数据填充到一个完整的数据包后再发送，减少报文数量。
	优化：建议开启，提升网络效率
	
tcp_nodelay;
	作用：禁用Nagle算法，允许发送小数据包，降低延迟
	优化：对于需要低延迟的交互式应用(如API、WebAPP)建议开启，通常与tcp_nopush互补使用
	
keepalive_timeout 75s;
	作用：客户端连接保持时间
	优化：适当降低(如30s)可以释放不必要的连接，节省资源；对于API网关可适当提高已减少TCP握手开销
	
keepalive_requests 100;
	作用：一个保持连接上最多可处理的请求数
	优化：可大幅提高(如 10000),让客户端能更长时间复用连接
	
client_body_timeout 60s;
client_header_timeout 60s;
	作用：客户端请求头和请求体的超时时间
	优化：根据业务调整，防止慢速客户端攻击，通常设为10s
```

例子

```nginx
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    keepalive_timeout 30s;
    keepalive_requests 10000;
    
    client_body_timeout 10s;
    client_header_timeout 10s;
}
```



### 维度3：静态资源与压缩优化(Disk I/O & CPU)

```
gzip on;
	作用：启用压缩，减少传输数据量
	优化：必须开启，对文本(HTML,CSS,JS,JSON,XML)内容压缩效果显著

gzip_comp_level 1;
	作用：压缩级别(1~9)，越高-压缩比越大，越消耗CPU
	优化：权衡选择，通常4和6是性价比最高的选择
	
gzip_min_length 20;
	作用：小于此长度的内容不压缩(单位：字节)
	优化：防止压缩小体积文件反而增加体积，可设为1k

gzip_types text/html;
	作用：指定需要压缩的MIME类型
	优化：可以添加更多类型：text/css application/javascript application/json ...

open_file_cache;
	作用：缓存文件元数据(描述符、大小、修改时间),减少磁盘IO
	优化：对静态资源服务器极其重要，能大幅减少stat()系统调用

expires;
	作用：再HTTP响应头中添加Expires或Cache-Control，让浏览器缓存静态资源
	优化：再location块中为图片、CSS、JS等设置长期缓存
	
关于静态资源缓存的优化参考维度4
```

例子

```nginx
http {
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_min_length 1024;
    gzip_ypes
        text/plain
        text/css
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml;
    
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    server {
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 365d;
            add_header Cache-Control "public, immuteable";
        }
    }
}
```

### 维度4：反向代理优化(Upstream & Proxy)

为nginx作为后端应用(如PHP、Node.js、java)的反向代理时

一、核心代理指令 (必须配置)

```
proxy_pass http://backend;
核心指令，定义请求被转发到的后端服务器地址或 upstream 组。
```

二、连接与超时控制 (稳定性关键)

```
proxy_connect_timeout 5s;
与后端服务器建立连接的超时时间。必须设置，防止长时间挂起。

proxy_send_timeout 30s;
向后端发送请求的超时时间。指两次连续的写操作之间的最长时间。

proxy_read_timeout 30s;
从后端读取响应的超时时间。指两次连续的读操作之间的最长时间。对于慢接口尤其重要。
```

三、请求头管理 (确保后端获取正确信息)

```
proxy_set_header Host $host;
最重要的头部设置。确保后端服务能接收到原始主机名。

proxy_set_header X-Real-IP $remote_addr;
传递客户端的真实 IP 地址，否则后端看到的是 Nginx 的 IP。

proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
传递整个代理链的 IP 列表，用于追踪请求来源。

proxy_set_header X-Forwarded-Proto $scheme;
告知后端客户端使用的协议是 http还是 https。
```

四、上游容错与负载均衡 (高可用核心)

后端服务器集群参数

```
server 10.0.0.1:8080 weight=5 max_conns=100 max_fails=3 fail_timeout=30s;
定义后端服务器地址，可设置weight权重、最大并发连接数防止单台过载、
最大失败次数、失败后暂停服务时间用来剔除故障节点。

server 10.0.0.3:8080 backup;
标记备用服务器，其他服务器不可用时才使用

server 10.0.0.3:8080 down;
手动标记永久不可用

proxy_next_upstream error timeout http_500;
定义在何种情况下（如错误、超时、5xx错误）尝试下一台后端服务器。

least_conn;
负载均衡策略。将请求发给当前连接数最少的后端，比默认轮询更公平。

ip_hash;
会话保持策略。根据客户端 IP 哈希固定分配到一台服务器。

keepalive 100;
性能关键 与上游服务器保持的长连接池大小，极大减少 TCP握手开销。

keepalive_requests 1000;  # 每个连接处理1000次请求后关闭
单个长连接处理的请求上限，防止内存泄漏。

keepalive_timeout 30s;    # 30秒无请求则关闭连接
空闲连接的保持时间。
```

五、缓冲与缓存 (性能优化利器)

Nginx像后端请求静态资源需要配置缓存，请求API接口需要配置缓冲。API接口请求的数据通常是动态生成的(比如订单信息)，每次请求的数据都不同，不适合缓存。而静态资源的内容是固定不变的，非常适合缓存，缓存这些静态文件可以减轻后端服务器的压力。

缓存的作用：将后端服务器发送的静态资源缓存到nginx服务器，减轻后端服务器的压力

缓冲的作用：开启缓冲nginx接收到后端服务器的响应，不会立刻将所有数据转发给客户端，二十暂存在自己的缓冲区里。1.后端速度比客户端快时，可以让后端服务器尽快释放连接，去处理其他请求，提高效率。

```
缓冲：
proxy_buffering on;
是否启用缓冲。默认开启，建议保持。缓冲可减轻后端压力。

proxy_buffers 8 32k;
设置用于读取后端响应的缓冲区数量和大小。

proxy_buffer_size 16k;
设置用于读取后端响应头的缓冲区大小。



=====================================================================

缓存：
代理缓存的配置分为两个部分：1. 定义缓存路径 (proxy_cache_path) 和 2. 启用并控制缓存行为

一、定义缓存区域：proxy_cache_path
proxy_cache_path /path/to/cache levels=1:2 keys_zone=MY_ZONE:10m inactive=60m max_size=10g use_temp_path=off;
说明

/var/cache/nginx
缓存文件存放的磁盘路径。需要确保目录存在且 Nginx 有写入权限。

levels=1:2
缓存目录的层级结构。1:2表示两级子目录，有助于管理大量文件。通常保持默认即可。

keys_zone=MY_CACHE:10m
定义共享内存区域。
- MY_CACHE：区域名称，后续会引用。
- 10m：分配 10MB 内存用于存储缓存键和元数据。1MB 约可存储 8000 个键。

inactive=60m
缓存的有效期。如果在 60 分钟内没有被访问，即使它未过期，也会被删除。这是管理存储空间的重要手段。

max_size=10g
缓存仓库的最大磁盘容量。当容量达到此值时，Nginx 会启动淘汰进程，删除最近最少使用的缓存。

use_temp_path=off
强烈建议设置为 off。这将避免在存储缓存时进行不必要的数据拷贝，提升性能。

----
二、启用与控制缓存行为
这些指令在 server或 location上下文中使用，用于决定如何缓存哪些内容。

1. 基本启用指令
proxy_cache MY_CACHE;
启用缓存，并指定使用哪个 keys_zone定义的缓存区域。

proxy_cache_key "$scheme$request_method$host$request_uri";
定义生成缓存键的规则。默认通常足够，特殊需求（如区分设备）时可修改。

proxy_cache_valid 200 302 10m;
proxy_cache_valid 404 1m;
proxy_cache_valid any 5m;

最重要的指令之一。为不同的响应码设置不同的缓存时间。
- 200/302 状态码缓存 10 分钟
- 404 状态码缓存 1 分钟
- 其他所有状态码缓存 5 分钟

2. 高级行为与控制指令
proxy_cache_min_uses 1;
一个请求被缓存前所需的最少访问次数。设为 1表示第一次访问就缓存。

proxy_cache_use_stale error timeout updating;
提升可用性的关键。当与后端通信出现错误、超时或正在更新缓存时，Nginx 可以返回旧的（stale）缓存数据。

proxy_cache_background_update on;
允许 Nginx 在后台更新过期的缓存，同时先返回旧的缓存内容。用户体验更好。

proxy_cache_bypass $http_cache_purge;
定义哪些情况不从缓存中读取（直接代理到后端）。常用于强制刷新缓存的条件。

proxy_no_cache $http_pragma;
定义哪些情况不缓存响应。例如，当请求头中包含 Pragma: no-cache时。

proxy_cache_lock on;
当多个请求同时未命中缓存时，只让一个请求去后端获取，其他请求等待，防止缓存击穿。

add_header X-Cache-Status $upstream_cache_status;
调试神器。在响应头中添加一个字段，显示请求的缓存状态（HIT, MISS, BYPASS, EXPIRED等）。

```



例子

```nginx
http {
    # 定义上游服务器组（后端服务）
    upstream backend_servers {
        least_conn;                  # 最少连接负载均衡
        server 10.0.0.1:8080 weight=5 max_fails=3 fail_timeout=30s;
        server 10.0.0.2:8080 max_fails=3 fail_timeout=30s;
        keepalive 100;               # 维持到后端的空闲长连接数
        keepalive_requests 1000;
        keepalive_timeout 30s;
    }

    # 定义缓存路径（关键！）
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC_CACHE:10m 
                     inactive=24h max_size=10g use_temp_path=off;

    server {
        listen 80;
        server_name example.com;

        # 静态文件服务（直接缓存）
        location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
            proxy_pass http://backend_servers;
            proxy_cache STATIC_CACHE;                    # 启用缓存
            proxy_cache_valid 200 302 365d;              # 成功响应缓存1年
            proxy_cache_valid 404 5m;                    # 404缓存5分钟
            proxy_cache_use_stale error timeout updating; # 容错：错误时返回旧缓存
            proxy_cache_background_update on;            # 后台更新缓存
            proxy_cache_lock on;                        # 防止缓存击穿
            add_header X-Cache-Status $upstream_cache_status; # 调试头

            # 缓冲控制（大文件优化）
            proxy_buffering on;
            proxy_buffers 8 32k;
            proxy_buffer_size 16k;

            # 请求头传递
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # API动态请求（缓冲但不缓存）
        location /api/ {
            proxy_pass http://backend_servers;
            proxy_buffering on;        # 启用缓冲保护后端
            proxy_buffers 8 32k;       # 缓冲区数量和大小
            proxy_buffer_size 16k;     # 响应头缓冲区大小

            # 超时控制
            proxy_connect_timeout 5s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;    # 根据API实际响应时间调整

            # 容错机制
            proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 2; # 最多尝试2台服务器

            # 请求头传递
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 缓存管理接口（可选：手动清除缓存）
        location ~ /purge(/.*) {
            allow 10.0.0.0/24;         # 只允许内网IP访问
            deny all;
            proxy_cache_purge STATIC_CACHE "$scheme$request_method$host$1";
        }
    }
}
```

## 优化流程总结

1.建立判断基线：在优化前使用监控工具(Prometheus，Grafana) 或命令 (vmstat，iostat，ss)记录当前的CPU，内存，磁盘IO，网络IO，和请求延迟数据



2.识别瓶颈：

​	连接数不足

​	CPU占用高

​	静态文件慢

​	代理后端慢



3.每次只修改一个参数，然后进行压测，对比基线数据

4.迭代进行：优化是一个持续的过程，要随着业务增长和技术变化，需要不断调整

# nginx静态网页优化

```nginx
user www-data;
worker_processes auto;
worker_rlimit_nofile 100000;

events {
    worker_connections 10240;
    multi_accept on;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # 日志设置
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # 压缩设置
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 5;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types 
        text/plain 
        text/css 
        text/javascript 
        application/javascript 
        application/json 
        application/x-javascript 
        text/xml 
        application/xml 
        application/xml+rss 
        text/javascript;

    # 传输优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay off;

    # 超时设置
    keepalive_timeout 65;
    client_header_timeout 15s;
    client_body_timeout 15s;
    send_timeout 10s;

    # 缓冲区设置
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;

    # 安全设置
    server_tokens off;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options nosniff;

    server {
        listen 80;
        server_name example.com;
        root /var/www/html;
        index index.html;

        # 静态资源处理
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 30d;
            add_header Cache-Control "public, max-age=2592000";
            access_log off;
        }

        location ~* \.(html|htm)$ {
            expires 10m;
            add_header Cache-Control "public, max-age=600";
        }

        # 限制请求体大小
        client_max_body_size 10m;
    }
}

```

```
调整内核参数（/etc/sysctl.conf）
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_tw_reuse = 1
提高系统文件描述符限制
echo "* soft nofile 100000" >> /etc/security/limits.conf
echo "* hard nofile 100000" >> /etc/security/limits.conf

连接超时与keepalive优化

keepalive_timeout 30;      # 保持连接超时时间
keepalive_requests 10000;  # 单个保持连接的最大请求数
reset_timedout_connection on;
client_body_timeout 10;
client_header_timeout 10;
send_timeout 2;

优化磁盘I/O

aio threads;
directio 4m;  # 对于大文件缓存
gzip_min_length 1024;      # 仅压缩大于1KB的文件
gzip_comp_level 4;         # 压缩级别适中，平衡CPU消耗
worker_connections 20000;      # 提高每个工作进程的最大连接数
multi_accept on;           # 允许工作进程同时接受多个新连接
use epoll;                 # 使用高效的epoll事件模型

代理连接优化

proxy_connect_timeout 3s;
proxy_send_timeout 5s;
proxy_read_timeout 8s;
```



# 一些问题

## Location语法

```
location的匹配顺序是按优先级来的，Nginx会从最具体的匹配开始，找到第一个匹配项后通常就会停止搜索。

基础语法
location [ = | ~ | ~* | ^~ ] uri {
	...
}
=、~、~*、^~是匹配修饰符，决定如何匹配URI

精确匹配：=
最高优先级。只有URI完全等于uri时，匹配成功
location = /login {
	# 只有当请求路径是/login 时，才会进入这里
	# 例如 http://example.com/login
	# 优点：速度最快，不需要正则匹配
	# 场景：用于处理精确到某个文件或路径的请求，比如首页、登录页
}

前缀匹配：^~
location ^~ /static/ {
	# 匹配所有以 /static/开头的请求
	# 例如： http://example.com/static/css/style.css
	# http://example.com/static/images/logo.png
	# 匹配成功就不再往下搜索正则表达式location
	# 优点：比~更快，不是正则表达式，匹配成功不再往下搜索
	# 使用场景：用于处理静态文件，因为这类文件通常在一个固定的路径下
}

普通前缀匹配：无修饰符
location /api {
	# 匹配以/api开头的请求
	# 如果一个请求有多个普通前缀匹配 匹配上，选择匹配路径最长的那个(最长路径有限)
	# 如果一个请求同时有普通前缀匹配 和 正则表达式 匹配上，有限使用正则表达式匹配的location
}

正则表达式：~和~*
~：区分大小写的正则表达式
location ~ \.(gif|jpg|jpeg|png)$ {
	# 匹配所有以.gif、.jpg、.jepg、.png结尾的URI，并且大小写敏感
}
~*：不区分大小写的正则表达式
location ~* \.(gif|jpg|jpeg|png)$ {
	# 匹配所有以.gif、.jpg、.jepg、.png结尾的URI，并且不区分大小写
}
```











## worker_connection为什么设为65536

```
最大并发连接数=worker_processes x worker_connections

TCP端口范围是0-65535，所以设为65536

在高并发场景和反向代理场景中：
长连接应用会占用大量持久连接，同时nginx需要维持和后端服务器的连接

所以设成最高值65536
如果发现连接数接近 65536，但硬件资源还很充裕，说明这个配置起到了应有的作用，您可以根据需要进一步调高它。
如果发现带宽或CPU先达到100%而连接数远低于65536，这恰恰证明了您的配置是成功的——瓶颈出现在了它应该出现的地方
```

## worker_rlimit_nofile要设为多少

```
nginx消耗FD的场景：
1. nginx进程与客户端建立连接会消耗一个FD，
2. 读取一个文件需要消耗一个FD，
3. 与上游通信会消耗一个FD，
4. 一些内部功能或其他模块也可能需要消耗FD

因此work_rlimit_nofile必须大于worker_connections
即work_rlimit_nofile = worker_connection + 安全裕量

65536是一个安全且简单的起点，更专业的做法是预估，例如平均每次网络连接会触发0.1个静态文件读取和建立0.1个后端连接，那么worker_rlimit_nofile = worker_connections * ( 1 + 0.1 + 0.1 ) = 78643,所以work_rlimit_nofile = 80000
系统软上限和硬上限也要设置成大于这个80000
```

## epoll模型和传统阻塞IO模型

```
传统阻塞I/O模型(例如Apache)每个连接占用一个线程/进程，消耗大量资源。进程进行系统调用时，如果数据未就绪，进程就会被挂起，直到内核完成操作。所以并发连接越多，线程越多，占用内存越多，进程多会导致频繁上下文切换。

epoll是Linux下高效的多路服用机制，允许单线程处理数万并发连接。通过epoll——wait()批量监听多个文件描述符，并且只返回有事件(如数据到达)的fd
```

## multi_accept on和accept_mutex off的效果

```
首先Nginx接受连接的流程：
当客户端发起新连接：
1.内核TCP协议栈完成三次握手
2.Nginx工作进程通过事件驱动机制(即epoll)感知新连接
3.进程调用accept()系统调用从内核的已完成连接队列中取出连接
multi_accept和accept_mutex控制工作进程拿连接的行为

multi_accept
开启时：一个工作进程在一次事件循环中，会尽可能多的accept()当前已就绪的所有新连接
关闭时，一个工作进程只accept()一个新连接(即使有多个连接就绪)
开启会减少用户态和内核态的切换和事件处理的开销

accept_mutex
开启时Nginx会有一个互斥锁让工作进程轮流接受新连接
关闭时Nginx工作进程自有竞争新连接(内核会通过 epoll的 EPOLLEXCLUSIVE标志避免"惊群效应")
锁的竞争导致上下文切换，现代Linux已解决惊群问题，多个进程同时accept()是安全的。所以要关闭

惊群效应：当多个进程（或线程）都在等待同一个资源（如一个新连接）可用时，当资源就绪，所有等待者都被唤醒去竞争，但最终只有一个能成功获取资源，其他人白忙活一场，导致大量的上下文切换和CPU资源浪费。

EPOLLEXCLUSIVE（Linux 4.5+）：这是 epoll的一个标志。当使用 epoll_ctl()添加监听套接字时带上这个标志，内核会保证只唤醒一个正在 epoll_wait()的进程，从而完美避免了惊群效应。
```

## sendfile on;tcp_nopush on;tcp_nodelay;

```
sendfile on;
启用Linux的sendfile()系统调用，实现文件数据从磁盘到网卡的零拷贝(Zero-Copy)传输
传统文件传输：
	磁盘文件->内核缓冲区->用户空间缓冲区->内核Socket缓冲区->网卡
	
sendfile on流程
	磁盘文件->内核缓冲区->网卡
	
	
tcp_nopush on;优化数据包填充，增加带宽利用率，但会增加大包的延迟
强制等待数据包填满最大报文大小后再发送。再发送大文件时，要尽量将每个TCP包填满

tcp_nodelay on;打开会禁用Nagle算法，减小小包的延迟
Nagle算法：会缓冲小数据包，直到收到前一个数据包的ACK或这个小数据包累积到足够大的数据量才会发送。这会导致延迟。再一些需要低延迟的场景(Websocket，实时游戏、API请求)需要打开这个选项

Wireshark 抓包验证
tcp_nopush on+ 大文件：可见平均包大小 ≈ MSS（如 1460 字节）
tcp_nodelay on+ 小请求：如 HTTP 响应头会立即发出（无延迟）

注意：
1. tcp_nopush 和 tcp_nodelay 不是互斥的
内核会智能处理：大包用 nopush，小包用 nodelay
2. sendfile不能用于压缩内容
若启用gzip，sendfile会被自动禁用(应为nginx要在用户态压缩数据)



静态内容服务器：
sendfile on;
tcp_nopush on;
tcp_nodelay on;

API/实时服务
sendfile off; #动态内容无需sendfile开不开一样，因为没用磁盘文件
tcp_nopush off;	#无需优化大包，减小延迟
tcp_nodelay on;	#降低延迟

混合型
#全局开启
sendfile on;
tcp_nopush on;
tcp_nodelay on;
#特定路径关闭
location /api/ {
	tcp_nopush off;
}
```

## keepalive_timeout、keepalive_requests、client_body_timeout、client_header_timeout

```
keepalive_timeout
客户端与Nginx之间建立的TCP长连接保持打开的最长时间
高并发短连接(如API网关)
keepalive_timeout 30s;#减少空闲连接占用资源
大量长连接场景(WebSocket)
keepalive_timeout 300s;	#避免频繁重置建立连接
静态资源服务器
keepalive_timeout 75s;#nginx默认75s，平衡连接服用和资源释放


keepalive_requests
单个TCP长连接上允许的最大HTTP请求数量，当一个TCP连接发送达到这个设定的阈值，即使未超时，Nginx会主动关闭连接
高负载API服务
keepalive_requests 1000;#提高连接复用率，减少握手开支
防范恶意客户端
keepalive_requests 50;#限制单个客户端占用资源


client_body_timeout从客户端发送请求体开始算起
客户端发送的请求体(Request Body)时的超时时间(如POST表单上传文件)
默认60s
文件上传服务：
client_body_timeout 500s;#允许大文件上传
API网关
client_body_timeout 10s;快速失败，避免慢客户端阻塞

可以配合client_max_body_size使用，限制请求体大小
client_max_body_size 20M;

client_header_timeout从建立连接开始算起
客户端发送的请求头(Request Header)超时时间，默认60s
高安全性要求
client_header_timeout 5s;
高延迟网络
client_header_timeout 30s;
```

## 压缩缓存静态文件相关

```
gzip on;
对已压缩文件无效(.zip、.jpg、.jpeg、.mp4图像文件都是被有损压缩过)

gzip_comp_level 1;
级别	CPU 开销	典型压缩比（HTML/CSS）
1		最低		~30%
6		中等		~70%
9		最高		~75%

gzip_min_length 1k;
单位字节，仅压缩大于指定大小的文件，推荐1k

gzip_types 
  text/plain
  text/css
  text/javascript
  application/json
  application/javascript
  application/x-javascript
  application/xml
  application/xml+rss
  image/svg+xml;
指定需要压缩的 MIME 类型（默认仅压缩 text/html）避免压缩已压缩的格式（如 image/jpeg, video/mp4）。
```

```
open_file_cache
缓存静态文件的元数据，减少磁盘IO
open_file_cache max 1000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
errors off;
max=1000：最多缓存 1000 个文件的元数据。
inactive=20s：20 秒内未被访问的缓存条目将被移除。
valid=30s：每 30 秒检查一次文件是否修改。
min_uses=2：文件至少被访问 2 次才会被缓存。
errors off：不缓存访问失败的文件信息（避免缓存错误状态）。

expires 365d;浏览器缓存时间


open_file_cache缓存的元数据（Metadata）
元数据类型	说明	示例值
文件路径	文件的磁盘路径	/var/www/image.jpg
文件描述符（FD）	内核中打开文件的引用标识	fd=17
文件大小	文件的字节数	size=248576
修改时间（mtime）	文件最后修改的时间戳	mtime=1653042823
访问权限	文件的读写权限	mode=644
```

## 关于域名解析

```
在nginx中，直接写死的域名。例如proxy_pass http://example.com:8080;
只会在nginx启动时进行一次域名解析，然后将解析结果缓存到nginx进程的内存中。

这对于一些域名的ip地址会发生变化的情况，不行

使用变量存储域名：每次请求都会进行重新解析。因为变量的值可能会动态变化，例如变量值可能从请求头、URI中获取，导致每次请求都不同，nginx在代码设计时就让使用变量存储的域名每次请求都进行动态解析
动态解析处理要使用变量存储域名，还需要指定resolver，不指定会报错
resolver 8.8.8.8 1.1.1.1; #这样每次都会解析域名
set $winpay "oapi.winpay.top";

可以结合valid选项控制该变量域名解析的行为,如下，该参数仅对动态解析域名生效。动态解析域名会缓存300s，超过300s会重新解析
resolver 8.8.8.8 1.1.1.1 valid=300s;
set $winpay "oapi.winpay.top";

```





# Nginx连接模型优化

```nginx
#64核主机
user www-data;
worker_processes auto;
worker_cpu_affinity auto; #将每个worker进程绑定到特定地CPU核心，避免进程在核心之间跳转造成性能损失
pid /run/nginx.pid;
worker_rlimit_nofile 80000;

events {
	user epoll;
    worker_connections 65526; #将worker每个进程地连接容量提升到65536，消除连接数成为瓶颈地风险
    multi_accept on;
    accept_mutex off;
}

#操作系统优化
#ulimit -s 100000
#ulimit -n 100000
#vim /etc/security/limits.conf
#* soft nofile 100000
#* hard nofile 100000
```





# nginx的LRU算法

```bash
Least Recently Used(LRU)，最近最少使用
Nginx的LRU判断机制是由一个独立的、异步的Cache Manager进程完成的

Cache Manager决定一个Key是否应该被移除，主要基于两个维度：访问时间和空间限制

#维度一：访问时间(atime)
Cache Manager进程通过文件系统记录的文件的访问时间atime来判断Key的热度
逻辑判断：Cache Manager周期性地判断所有缓存文件atime
	依据：在空间不足需要清理的时候,atime最久远(即最久未被访问)的文件会被有限标记为最冷并被删除
	
#维度二：空间限制和过期状态
LRU清理会结合proxy_cache_path中设置的两个主要参数进行判断和操作
1.空间驱逐
参数：max_size
判断：当新的写入请求导致缓存总大小超过max_size时，Cache Manager启动清理
操作：从atime最早的文件开始，强制删除文件，直到总空间回落到安全限制以下

2.闲置驱逐
参数：inactive
判断：Cache Manager检查文件的atime
操作：任何文件的atime超过inactive设定的时间，即使缓存内容任未过期，会被标记为闲置并删除
```

```bash
#当LRU发现缓存空间紧张时，Cache Manager启动清理工作流程
优先级1：删除过期文件
删除超过proxy_cache_valid有效期的文件
优先级2：删除闲置文件
删除atime超过inactive设定时长的文件
优先级3：LRU驱逐
如果空间任然不足，Cache Manager开始按atime从旧到新的顺序删除文件，知道容量低于max_size限制
```



# Nginx日志与变量

```bash
log_format cache_debug '$remote_addr - $remote_user [$time_local] "$request" ''$status $body_bytes_sent '
'Cache_Status:$upstream_cache_status ' 'Key_Scheme:$scheme ' 'Key_Host:$host ' 'Key_URI:$uri ' 'URI:$request_uri';
```

```bash
#核心HTTP变量(请求和响应)
$uri #标准化后的请求URI，不包含查询字符串和参数，例如/public/images/test.png

$request_uri #原始请求URI，包含完整查询字符串和参数，例如/public/images/test.png?v=123

$scheme #请求使用的协议，例如http

$host #请求头的Host字段值

$remote_addr #客户端IP地址

$server_addr #接受请求的服务器IP地址

$request_method #HTTP请求方式，例如GET、POST

$status #发送到客户端的响应状态码

$body_bytes_sent #发送到客户端的字节数


#HTTP请求头和响应头变量


#缓存变量
$upstream_cache_status #缓存状态。MISS、HIT、STALE、EXPIRED等

#自定义变量
#由于键值的键无法直接通过变量引用，但可以通过set自定义变量在日志里展示
#在server块或者location块中定义变量,方便观察可以用:分割
set $def_cache_key "$scheme:$host:$request_uri"
#然后再日志里使用自定义变量
```

