# 基本语法

```
sort [选项] [文件]
如果未指定文件，则从标准输入读取数据
默认按照字典升序排序
```

# 常用选项

```
基本排序：
-r 降序
-f	忽略大小写(默认大写优先)
-d 进按照字母、数字、空格排序(忽略标点)
-n 数值排序
-h 人类可读数值排序
-M 按月份排序(JAN<FEB)

字段排序：
-t'SEP' 指定字段分隔符	sort -t':' file.txt
-kPOS	这个POS是指定的字段 sort -t',' -k2n,3r file.txt
解释：-k2n,3r指第2字段升序，第3字段字典降序
	-k2,3按第2字段到第3字段排序
	
其它功能：
-u 去重(等同于sort ... | uniq)  sort -u file.txt
-o file.txt 将结果输出到文件覆盖	sort file.txt -o sorted.txt
```

# 场景

```
sort -t',' -k3nr data.csv

awk 'BEGIN{FS=" "; count[]}{count[$7]++}END{for (ip in count){print ip, count[ip]}}' | sort -k2nr
```

