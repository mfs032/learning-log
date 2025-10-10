# awk(三个人的名字缩写)

## AWK基本语法

```bash
awk 'pattern{action}' inputFile
#pattern：匹配条件(可选)，如/正则表达式/或者$1 > 100
#action：要执行的操作，如print或者计算
#inputFile是输入的文件，如果不指定则要从|读入输入
```



## AWK的核心概念

字段和记录

```bash
记录(Record)：默认以\n分隔，即一行一条记录
字段(Field)：默认以空格或制表符分隔记录获得字段，字段存储在$1, $2,...NF
	$0：表示记录，默认是当前一整行
	$1：表示分隔得到的第一个字段
	NF(Number of Fields)：当前行的字段数，列数
	NR(Number of Records)：当前记录的号，即行号
	
	
] awk -F':' '{print $1}' /etc/passwd
-F可以指定分隔符，默认空格
```



模式匹配

```bash
AWK可以基于正则表达式或者条件判断进行过滤

#匹配带error的行
] awk -F' ' '/error/{print $0}' process.log

#匹配第三列大于100的行
] awk -F' ' '$3 > 100 {print $1,$3}' file.txt

特殊模式
BEGIN{...}：在处理文本前执行
END{...}：在处理文本后执行
] awk 'END{print NR}' file.txt #打印最后一行行号
```



变量与计算

```bash
#计算第二列和第三列的和
awk '{sum = $2 + $3; print $1, sum}' data.txt

#统计第二列的总和
awk 'BEGIN{sum = 0}{sum += $2}END{print sum}' data.txt


内置变量：
FS(Field Separator)：输入的字段分隔符
OFS(output Field Separator)：输出的字段分隔符
RS(Record Separator)：输入的记录分隔符
ORS(output Record Separator)：输出的字段分隔符
NF(number of Field)：当前记录的字段数量，即当前行的列数
NR(number of Record)：记录的号，即当前行的行号

在awk中变量和字段引用的方式不同：
引用字段要加上$，例如$1,$2,$3
引用变量不需要加$,直接使用变量名就行，例如FS，NR，NF，sum


自定义输入输出格式
]  cat /tmp/inputFile.txt | awk 'BEGIN{FS=";"; OFS="|"; sum = 0}{if (NF == 4){sum += $4; print $1,$2,$3}}END{print "总行数:",sum}'

```

  

## awk搭配正则表达式

```
awk的正则表达式通常用于 模式匹配（/pattern/）或 字符串函数（如 match()、sub()、gsub()）
```

### 1.基本匹配

```
awk '/正则表达式/{动作}' 文件
awk '/error/{print $0}' log.txt	#隐式匹配整行
awk 'if($0 ~ /error/){print $0}'
```

#### 整行匹配

```
awk '/^start/{print $0}'  # 匹配以 "start" 开头的行
awk '/end$/{print $0}'    # 匹配以 "end" 结尾的行
awk 'if($0 ~ /end$/){print $0}'
```

#### 字段匹配

```
awk '$2 ~ /正则表达式/{动作}'  # 对第2字段匹配
awk '$2 !~ /正则表达式/{动作}' # 不匹配
awk 'if($2 ~ /正则表达式/){动作}'
```

### 2.字符串函数+正则

#### 1.match()函数

```
检查字符串是否匹配某个模式，并提取匹配的子串
match(string, regexp [, array])
string
要匹配的输入字符串（通常是 $0整行或某个字段 $n）。
regexp
正则表达式（可以是 /pattern/或字符串形式 "pattern"）。
array（可选）
arr[0]：存储整个正则表达式匹配到的完整字符串
arr[1], arr[2], ..., arr[n]：依次存储第 1 个到第 n 个捕获组（用 () 定义的子表达式）匹配到的内容。

返回值
如果匹配成功，返回 匹配的起始位置（从 1 开始计数）。
如果匹配失败，返回 0
```

检查字符串是否匹配模式，如果行中包含 `error`，则输出行号（`NR`）。

```
检查字符串是否匹配模式
awk 'match($0, /error/) {print "Found error on line:", NR}' log.txt
```

提取匹配的第一个子串，`arr[0]`存储完整匹配的字符串。

```
echo "Date: 2023-10-01" | awk 'match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/, arr) {print arr[0]}'
# 输出：2023-10-01

➜  ~ echo "这是1980，不是1990" | awk 'match($0, /[0-9]+/, arr){for (i in arr){print i," "arr[i]}}'
0start  3	#匹配开始的位置，从1开始计数
0length  4	#匹配到的子串的长度
0  1980		#arr[0]

➜  ~ echo "这是1980，不是1990" | awk 'match($0, /[0-9]+/, arr){print arr[0]}'
1980


```

arr[1]和arr[2]等存储捕获分组

```
➜  ~ echo "User: john_doe (ID: 123)" | awk 'match($0, /User: ([A-Za-z0-9_]+).*ID: ([0-9]+)/, arr) {print "Name:", arr[1], "ID:", arr[2]}'
Name: john_doe ID: 123
```



#### 2.sub()和gsub()函数

修改文本一般使用sed

```
sub(/正则表达式/, "替换内容", 字段)：替换第一个匹配。
gsub(/正则表达式/, "替换内容", 字段)：替换所有匹配。

示例：替换所有 http://为 https://
awk '{gsub(/http:\/\//, "https://", $0); print}' urls.txt
```



# 常见问题

## 1.转义特殊字符

```
在 awk中，正则表达式的 /需要转义
awk '/http:\/\//{print}'  # 匹配 "http://"
```

## 2.默认区分大小写

```
使用 IGNORECASE=1忽略大小写
awk 'BEGIN{IGNORECASE=1} /error/{print}' log.txt
```

