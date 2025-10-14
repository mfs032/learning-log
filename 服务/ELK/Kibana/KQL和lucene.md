# KQL(Kibana Query Language)和Lucene查询语法的区别

```bash
KQL支持：
字段名称：支持自动补全
通配符：支持*和?
正则表达式：不支持
模糊查询：不支持
范围查询：支持，使用自然语言，例如response_code < 400
```

```bash
Lucene支持：
字段名称：需要输出完整字段名称
通配符：支持*和?
正则表达式：支持
模糊查询：支持，使用~
范围查询：支持，使用[]或{}，例如response_code:[200 TO 400]
```

# KQL

```bash
KQL核心目标是过滤数据，不用于排序、不用于聚合、不用于定义复杂的全文相关性评分

KQL语法主要分为自由文本搜索和基于字段的搜索两大类
```

## 自由文本搜索

```bash
直接输入不带字段名的词语或短语，Kibana会在配置的默认字段，例如
单个词语：查找包含该词语的文档	error
短语匹配：查找包含精确短语的文档 "payment failed"
```

## 基于字段的搜索

```bash
对特定字段进行精确过滤
等值匹配：status: 200
通配符匹配：client_ip: 10.1.1.*
短语匹配：user.name: "john doe"	#字段值包含该精确短语
存在检测：error.message: * 或 _exists_: error.message
字段排除：not error.message: *
```

## 关系运算符

```bash
关系运算符只能用于数值和时间类型的字段
>：bytes > 1024
>=：
<：
<=：
```

## 逻辑运算符

```bash
AND：例如status: 200 and method: POST  #逻辑与
OR：逻辑或
NOT：逻辑非
分组：使用括号定义优先级，例如(status: 500 or status: 503) and tag.uid: *
```



# Lucene

```bash
Lucene是ES的底层搜索库Apache Lucene使用的原始查询语言

#默认行为：全文搜索
默认字段：当只输入一个词语而没有指定字段时，Lucene会在ES配置的默认搜索字段(例如_all或message字段)进行全文搜索

分词匹配：搜索的词语会经过分词器处理，匹配文档中经过分词的词项，而不是精确的原始字符串
```

## 字段搜索

```bash
等值匹配：例如status:200
短语匹配：例如message:"payment failed"

决定:是等值还是包含取决于字段的类型text是包含，keyword是等于
```

## 逻辑运算符

```bash
Lucene的布尔运算符必须全部大写
AND：例如status:200 AND method:POST
OR：例如status:200 OR method:POST
NOT：NOT status:404
强制包含：例如+status:200 AND +method:POST或者+level:error +service:auth
强制排除：类似+，使用-作为强制排除-status:200 AND -method:POST
分组：使用括号定义优先级,例如(status:500 OR status:503) AND tag.uid:*
```

## 范围搜索

```bash
Lucene使用[]和{}定义范围
[]：闭区间，例如age:[18 TO 30] #值18到30
{}：开区间，例如age:{17 TO 31} #值18到30
TO：连接范围的开始和结束
```

## Lucene的高级搜索功能

```bash
Lucene比KQL主要多出这个功能
```

### 模糊搜索

```bash
语序查找与指定词项相似的词项，用于处理拼写错误或输入不准确
语法：在词项后加上~，可以附加一个数字作为模糊度(编辑距离)
格式：term~[fuzziness]
term是要查询词项，
fuzziness值：
	0表示精确匹配
	1表示语序一次编辑，即插入删除替换一个字符
	2默认值允许两次编辑
	
示例：
user.name:john~1
message:apple~
```

### 邻近搜索

```bash
指定要查找的短语中的所有词之间相隔的总单词数
格式："phrase term"~[distance]
distance值：指定要查找的短语中的所有词之间相隔的总单词数

示例：
message:"quick fox apple"~5	#搜索quick fox apple这三个词，他们之间间隔的单词加起来不超过5，对于匹配到的文档里这三个单词的顺序可能会不一样
```

### 范围搜索

```bash
见上一个范围搜索
```

### 通配符搜索

```bash
?匹配单个字符
message:t?st	#匹配test、tast等

*匹配0个或者多个字符
user.id:123*	#匹配所有123开头的用户id
```

### 正则表达式搜索

```bash
格式field:/pattern/

示例
ip:/192\.168\.0\.[0-9]{1,3}/
product_code:/P[0-9]{3}A/	#匹配以P开头，后跟3位数字，以A结尾
不支持^和$,默认匹配字段的全文
```

### 术语提升

```bash
用于影响搜索结果的相关性评分，不会改变文档是否匹配，会使包含被提升词项的文档在结果排名中更靠前
格式：term^factor
factor值：
	大于1.0(默认值)会提高相关性
	小于1.0会降低相关性

示例
title:error^2 OR body:error
```



# 一些问题

## text字段与""与分词

```bash
tag.error:客户
tag.error:"客户"

tag.error是text类型字段，所以会使用一个分词器
例如tag.error:客户	会被分为客和户，查询包含客或户的文档
#匹配内容有如下
客户:M-2不在白名单客户配置中
剧集C296DEDB976E306E9D6A1094BA86DB23与门户masnew不匹配
查询语句
"must": [
        {
          "query_string": {
            "query": "tag.error:客户",
            "analyze_wildcard": true,
            "time_zone": "Asia/Shanghai"
          }
        }
      ]


例如tag.error:"客户"
带引号会触发短语查询
首先进行分词处理得到客和户
短语查询会寻找索引中连续包含客和户的文档
并没有绕过分词，而是要求分词的结果在文档中的文职和顺序
#匹配内容如下
客户:M-2不在白名单客户配置中
客户:M-3不在白名单客户配置中
查询语句
"must": [
        {
          "query_string": {
            "query": "tag.error:\"客户\"",
            "analyze_wildcard": true,
            "time_zone": "Asia/Shanghai"
          }
        }
      ]
      
      
使用tag.error:"客户 M-2"和tag.error:"客户:M-2"查询到的内容是一样的，证明了""包裹依旧会被分词
```

## 查询内容包括`:`

```bash
使用\转义
tag.error:客户\:M-2
tag.error:"客户\:M-2"	#""包裹的:可以不加\推荐加
```

