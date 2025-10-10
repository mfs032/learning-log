# JSON

JSON主要有两种基本结构组成：

`键值对集合(对象)`：可以理解成字典或者哈希表

`值列表(数组)`：可以理解成列表。用[]包围，内部是一系列，分割的值，可以是不同类型

## JSON支持的数据类型

字符串(String)：用""包围

数字(Number)：可以是整数或浮点数

布尔值(Boolean)：true或false

空值(Null)：null

对象(Object)：上述的键值对集合

数组(Array)：上述的值列表

## 例子

```json
{
  "name": "Jane",
  "age": 30,
  "isStudent": false,
  "hobbies": ["reading", "hiking", "coding"],
  "address": {
    "city": "New York",
    "zipCode": "10001"
  },
  "courses": [
    {
      "title": "Math",
      "credits": 3
    },
    {
      "title": "History",
      "credits": 4
    }
  ]
}
```



# **JSON Query**(jq)

## 例子

```json
{
  "name": "Alex",
  "age": 28,
  "roles": ["admin", "editor"],
  "contact": {
    "email": "alex@example.com",
    "phone": "123-456-7890"
  },
  "isActive": true
}
```



## 1. `.`(点号)-根对象和访问属性

`.`代表整个输入的JSON数据。它是所有操作的起点

#### 获取整个JSON

```shell
] jq '.' user.json
#这回输出user.json的内容
```



#### 访问键(属性)

在`.`后面加上键名，可以访问该键的值

```shell
] jq '.name' user.json
#输出"Alex"
```

对于嵌套的对象，用`.`串联

```shell
] jq '.contact.email' user.json
#输出alex@example.com
```



## 2. `[]`(方括号)-数组操作

#### 遍历数组

在数组键后加上[]，可以遍历并逐行输出数组中的每个元素

```shell
] jq '.roles[]' user.json
#输出
#"admin"
#"editor"
```

#### 通过索引访问

在[]中传入索引(从0开始)，可以访问数组的特定元素

```shell
] jq '.roles[0]' user.json
#输出"admin"
```



## 3. `|`(管道)-链式操作

将前一个表达式作为后一个表达式的输入，实现链式处理

#### 数据转换

ascii_upcase是jq的内置函数

```shell
jq '.roles[] | ascii_upcase' user.json
#输出
#"ADMIN"
#"EDITOR"
```



## 4. `{}`(花括号)-创建新对象

花括号用来创建一个新的JSON对象，可以筛选部分字段并重新组织

#### 提取字段

提取name和email组成新对象

```shell
jq '{name: .name, email: .email}' user.json
```



