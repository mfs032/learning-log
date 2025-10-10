# 用法

```
cut [选项]  [文件]
```

# 选项

按字符切割-c

```bash
echo $str | cut -c1
echo $str | cut -c1,2
echo $str | cut -c1-4
```

按字段切割-f ,  配合自定义分割符-d使用

-d默认是制表符

```bash
echo "apple,oragne,banana" | cut -f2 -d','
while IFS= read line; do echo "$line" | cut -f 1-3 -d $'\t'; done	#命令行指定\t时，用$'\t'
cut -c3-	#输出到结尾

```

