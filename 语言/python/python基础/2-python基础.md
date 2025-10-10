# **1. 变量（Variable）**

变量是程序中用于存储数据的“命名容器”。Python 是动态类型语言，变量不需要提前声明类型，可以直接赋值使用。

**变量的特点**

**无需声明类型**：Python 变量类型由赋值的数据自动推断。

**可重新赋值**：变量可以随时修改其值和类型。

**变量名区分大小写**：`name`和 `Name`是不同的变量。

```python
x = 10          # 整数变量
name = "Alice"  # 字符串变量
pi = 3.14       # 浮点数变量
is_active = True  # 布尔变量

x = 10
print(x)  # 输出: 10

x = "Hello"  # 变量类型可以改变
print(x)  # 输出: Hello
```

**多变量赋值**

```python
python允许同时给多个变量赋值
a, b, c = 1, 2, 3
```

# **2. 标识符（Identifier）**

标识符是变量、函数、类、模块等的名称。Python 有一套命名规则，即规范：

**标识符命名规则**

**只能包含**：

字母（`A-Z`, `a-z`）,数字（`0-9`，但不能开头）,下划线（`_`）

**不能以数字开头**：

✅ `name`, `_age`, `user1`

❌ `1user`, `123abc`

**区分大小写**：

`count`和 `Count`是不同的标识符。

**不能使用关键字**：

Python 的关键字（如 `if`, `for`, `class`）不能用作变量名。



# 3.数值类型、字符串、格式化输出

数值类型：int整形，float浮点数，bool布尔型

字符串：str,需加上""或者''包裹，包含所行内容是使用''''''包裹

```python
print(f"hello${num}")
```



# 4.算数赋值、输入、转义

```python
+-*/%

num = 5
num += 5
num -= 5

input()
input("请输入姓名")
name = input()
num = int(input())

\转义字符
\t制表符, \n换行符，\r回车符，\\表示转义 转义字符
print("你好\t你好")
\r回车表示将当前位置移到开头
print("你好\r不好")	#只会输出不好


```



# 5.if判断、比较运算、逻辑运算

```python
if 判断逻辑:
    执行逻辑
    


==, !=, >, <, >=, <=

not and or
```



# 6.if-else，if-elif-else嵌套

```python
if 判断逻辑:
    执行逻辑
else:
    执行逻辑
    
    
    
if 判断逻辑:
    pass
elif 判断逻辑:
    pass
else:
    pass
```



# 7.while循环与循环嵌套

```python
while 判断逻辑:
	循环体
    
while True:
    循环体
    

```



# 8.for训话。continue，break

```python
str = "sadacnaib"
for i in str:
    循环体
    if 判断条件:
		continue
    if 判断条件:
		break

        
range()函数,左开右闭
start，stop，step参数

for i in range(1,6):
    pass

```



# 9.编码方式，字符串常见操作

用utf-8就对了

下标与切片  使用 str[num1:num2:num3] 切片，开始(包括)，结束(不包括)，步长，

```python
name = "lijunhua"
print(name[0])
name_2 = name[2]

name[0:2]	#li
name[0:4:2]	#lj

name[0:] #lijunhua
name[:7] #lijunhu
```



# 10.字符串查找、判断、修改

```python
#查找
1. 
find(要查找的子字符串,开始位置下标,结束位置下标)查找，开始-结束是左闭右开
找到子字符串会返回开始位置下标，找不到会返回-1

name = "lijunhua"
name.find("i")

2. 
index(要查找的子字符串，开始位置下标，结束位置下标)，开始-结束左臂右开，使用方式和find()相同
找到会返回开始位置下标，找不到会报错


3. 
count(子字符串，开始，结束)左闭右开，找出子字符串出现的次数，没有就返回0
name.count("i")



```

```python
#判断
4.
startswith(子字符串，开始，结束)左闭右开，找出开始是否是以子字符串开始，是返回True，不是返回False

5.
endswith(子字符串，开始，结束)是否以子字符串结尾，是返回True，不是返回False

6.
isupper()检测字符串是否全是大写字母，是返回True
print(name.isupper())	#打印False
```

```python
#修改
1.
replace(旧内容，新内容，替换次数)，替换次数省略默认全部替换
name = "abcdefggggabcd"
name.replace("a","ooo")
name.replace("a","ooo",1)


2.
split(指定字符串,指定分割次数)，指定字符串来切分字符串，分割次数不指定，默认全部分割
name = "a,b,v,r,ssss,rrr,a"
name.split(",")
name.split("")


3.
capitalize()，将第一个字母变成大写
name.capitalize()

4.
lower()，将所有大写字母转为小写
name.lower()

5.
upper()，将所有小写字母改为大写
name.upper()
```



# 11.列表定义，列表增删改查，列表推导式，嵌套

```python
#定义
所有元素放在[]中，元素与元素之间用,隔开
元素之间的数据类型可以不相同
li = [1,2,3,4]
li2 = [1,2,"name",4]

有下标就可以进行切片操作
li[1:2]

列表是可迭代对象，可以使用for循环遍历取值
for i in li:
    pass
```

```python
#增
在列表结尾添加元素
append() 

在指定索引处插入元素
name = ["second","thrid"]
insert()
name.insert(0,"first")	#name = ["first","second","thrid"]

将另一个类型中的每一个元素注意添加到列表的结尾
extend()
name = ["one","two","three"]
name.extend("four")	# name = ["one","two","three","f","o","u","r"]
name2 = ["one","two"]
name.extend(name2)	#name = ["one","two","three","f","o","u","r","one","two"]


```

```python
#改
直接通过下标修改
name = [1,2,3]
name[0] = 5	# name = [5,2,3]
```

```python
#查
in：查找指定元素是否在列表中，在返回True，不在返回False
not in：

name = ["li","jun","hua"]
if "hahha" in name:
    pass
else:
    pass

```

```python
#删除
1.
del
li = [1,2,3]
del li[0] #删除对应下标 li = [2,3]
del li	#删除li这个列表

2.
pop()：删除指定下标的元素，不指定，就删除最后一个
li = [1,2,3,4,5]
li.pop() # li = [1,2,3,4]
li.pop(2) # 删除2下标的元素 li = [1,2,4]

3.
remove()：根据元素的值删除第一个出现的元素,删除不存在的元素会报错
li = [1,2,3,4,5,6,7,6]
li.remove(6) # li = [1,2,3,4,5,7,6]，第一个6被删除
```

```python
#常见操作
1.
排序
sort()：将列表重新排序，从小到大
reverse()：倒序，将列表整个倒序，倒过来
li = [6,7,1,3,5]
li.sort()	#会将li升序，li = [1,2,5,6,7]
li.reverse()	#会将li倒序 li = [7,6,5,2,1]


2.
列表推导式
[表达式 for 变量 in 可迭代对象 判断条件]
li = [num*num for num in range(1, 6) if num > 3]
print(li) # [16,25]
```

# 12.元组、字典、集合

```python
#元组
1.
tulpe 元组定义
用小括号定义，元素可以是不同类型，是由一个元素时，结尾要加,
tua = (1,2,3,"hahah")
#tua = (1,)
#tua = ()

2.
元组只支持查询操作，不支持修改
print(tua[0])
print(len(tua))

3.
应用场景
#作函数的参数和返回值
#格式化输出后面的(),本质上是一个元组
#数据不可被修改，保护数据安全
```

```python
#字段
1.
dict 字典定义
用大括号定义，元素以键值的形式定义
dic = {"name":"lijunhua", "age":19}
字典中的键不可重复，值可重复。如果定义的字典中有多个相同的键，前面重复的键会被最后一个覆盖，返回的值只有最后一个



2.
字段常见操作增删改查
#查
字典没有下标，查找元素要根据键名
print(dic["age"]) # 19 
#[]没有对应的键会报错，不推荐
print(dic.get("age")) # 19
#没有键不会报错，而是返回None


#改
通过key修改value
dic["age"] = 20

#增
使用[],这个[]有键值就修改，无键值就新增
dic["tel"] = 12345


#删


```

