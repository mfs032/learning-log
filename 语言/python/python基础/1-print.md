输出函数print()

# 参数

*object

```
表示可以传入任意数量的对象（用逗号分隔）。

这些对象会被转换为字符串并输出。

例如：print("Hello", "World", 123)会输出 Hello World 123。
```

sep(分隔符，默认是空格' ')

```
指定多个对象之间的分隔符
print("Hello","WORLD",seq=',')
```

end(结束符，默认换行'\n')

```
指定输出的末尾的字符
print("str",end=" ")，会输出str不换行
```

file(输出目标，默认sys.stdout)

```python
指定输出的文件对象，例如写入文件
with open("output.txt", "w") as f:
	print("HELLO WORLD",file=f)
```

