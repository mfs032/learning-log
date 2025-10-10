# sed命令

```
sed（Stream Editor）是 Linux/Unix 系统中强大的 流式文本处理工具，主要用于 文本替换、删除、插入、提取 等操作。它按行处理输入流，适合自动化脚本和大文件处理。
```

## 基本语法

```
sed [选项] '命令' 输入文件
sed [选项] -f 脚本文件 输入文件

选项			说明
-n			禁止自动打印模式空间（常与 p命令配合）
-e			指定多个命令（如 sed -e 'cmd1' -e 'cmd2'）
-f			从脚本文件读取 sed命令
-i			直接修改文件（慎用，建议先测试）
-E			启用扩展正则（ERE），默认是基础正则（BRE）
```

## 核心功能

### 1.文本替换

```
sed 's/原字符串/新字符串/[标志]' 文件
标志（flags）：
g：全局替换（默认只替换每行第一个匹配）
p：打印替换的行
i：忽略大小写（GNU sed支持）

sed 's/foo/bar/' file.txt        # 每行第一个 "foo" 替换为 "bar"
sed 's/foo/bar/g' file.txt      # 替换所有 "foo"
sed 's/foo/bar/2' file.txt      # 只替换每行第二个 "foo"
sed 's/foo/bar/gi' file.txt     # 全局替换，忽略大小写
```

### 2.删除行

```
sed 'Nd' 文件          # 删除第 N 行
sed 'M,Nd' 文件        # 删除 M 到 N 行
sed '/pattern/d' 文件  # 删除匹配的行

sed '3d' file.txt        # 删除第 3 行
sed '2,5d' file.txt      # 删除 2~5 行
sed '/error/d' log.txt   # 删除包含 "error" 的行
```

### 3.打印行

```
sed -n 'Np' 文件         # 打印第 N 行
sed -n '/pattern/p' 文件 # 打印匹配的行

sed -n '5p' file.txt       # 打印第 5 行
sed -n '/admin/p' log.txt  # 打印包含 "admin" 的行
```

### 4.插入追加替换行

```
i		在匹配行前插入
a		在匹配行后追加
c		替换匹配行

sed '2i\插入的内容' file.txt      # 在第 2 行前插入
sed '/pattern/a\追加的内容' file.txt # 在匹配行后追加
sed '/old/c\新行内容' file.txt    # 替换匹配行为 "新行内容"
```

### 5.行范围操作

```
sed 'M,N 命令' 文件  # 对 M 到 N 行执行命令
sed '/start/,/end/ 命令' 文件  # 对匹配 "start" 到 "end" 的行执行命令

sed '3,7s/foo/bar/g' file.txt      # 替换 3~7 行的所有 "foo"
sed '/start/,/end/d' file.txt      # 删除从 "start" 到 "end" 的行
```

## 正则表达式

```
sed默认使用 基础正则（BRE），-E启用 扩展正则（ERE）。
```

# 示例

```bash
#删除空白行
sed '/^$/d' file.txt
```

```bash
#替换日期格式（YYYY-MM-DD→ DD/MM/YYYY）
sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/g' dates.txt
```

```bash
#在匹配行后追加内容
sed '/server/a\    listen 80;' nginx.conf
```

