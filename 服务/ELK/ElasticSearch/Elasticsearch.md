# Elasticsearch概念

## 部署单节点ES

```
ES基于Java开发，需要在系统上安装JDK
官网下载免费已编译的ES包
] tar -xvf elasticsearch-8.11.0-darwin-x86_64.tar.gz
] cd elasticsearch-8.11.0
#启动Elasticsearch，默认监听9200端口
] ./bin/elasticsearch

#新开一个终端,验证是否部署成功
] curl http://localhost:9200/
```

## 核心概念

```
可以和传统关系型数据库类比
ES			  		关系型数据库		说明
索引(Index)		数据库(Database)	索引是文档的集合，是存储数据的地方
文档(Document)	行(Row)			 文档是ES中的基本数据单元，以Json格式表示

字段(Field)		列(Column)		文档中的属性或键，如title，tag.author。

映射(Mapping)		表结构(Schema)		定义索引中的文档包含哪些字段，定义字段的类型(text,keyword,integer)，相当于数据模式

查询(Query DSL)	SQL语句			用于搜索和检索数据的语言

```

```
说明：
文档(Docement)：是JSON格式，非常灵活，可以包含多个字段和嵌套结构
索引：不仅仅是数据的容器，通过倒排索引等技术，使文本搜索非常快
```

# 索引(Index)

```
在 Elasticsearch 中，“索引”这个词有动词和名词两种含义

动词（Indexing）：指存储数据到 Elasticsearch 中的过程。类似于向数据库“插入”一条记录。

名词（Index）：指存储数据的地方本身，是文档的集合。类似于关系型数据库中的“数据库”（Database）。


本质：
逻辑概念：它是你存储相关数据的地方，是同一类文档的集合。例如，你可以有一个 products索引来存储所有商品信息，一个 users索引来存储所有用户信息。


物理概念：索引的存储有两个概念,分片(shard)与副本(Replica)
ES会将一个索引拆分到多个分片中存储，每一个分片都是独立的Lucene索引，包含部分完整数据。


```

## 分片

1. 索引如何被拆分：分片（Shard）

```
主分片（Primary Shard）：
索引创建时指定的number_of_shards决定了主分片数量（默认 1 个），一旦创建不可修改。
例如，一个索引设置了 3 个主分片，数据会被均匀分配到这 3 个分片（通过哈希算法根据文档 ID 分配）。

副本分片（Replica Shard）：
主分片的冗余副本，由number_of_replicas指定（默认 1 个），可动态修改。
副本的作用是：① 故障容错（主分片宕机时，副本可升级为主分片）；② 分担查询压力（查询请求可分发到副本）。
```

2. 分片在集群节点中的分布

```
假设一个 ES 集群有 3 个节点（Node1、Node2、Node3），创建一个包含3 个主分片（P0、P1、P2） 和1 个副本（R0、R1、R2） 的索引，分布规则如下：

主分片：均匀分配到不同节点（避免单点故障）。
例如：P0 在 Node1，P1 在 Node2，P2 在 Node3。
副本分片：不会与对应的主分片在同一节点（否则节点故障会同时丢失主副分片）。
例如：R0（P0 的副本）在 Node2，R1（P1 的副本）在 Node3，R2（P2 的副本）在 Node1。
```

3. 总结：索引在集群中的存储逻辑

```
索引被拆分为多个主分片，分布式存储在不同节点。
每个主分片有若干副本分片，分布在其他节点，确保高可用。
客户端读写数据时，ES 会自动路由请求到对应的分片（写操作只在主分片执行，读操作可在主分片或副本分片执行）。
当集群节点增减时，ES 会自动重新平衡分片分布，保证负载均衡。
```

### 创建索引时指定分片和副本

```shell
curl -X PUT "localhost:9200/my-index" -H "Content-Type: application/json" -d"
{
	"settings": {
	  "number_of_shards": 3,	# 指定该索引有3个主分片
	  "number_of_replicas": 1	# 为每个主分片创建一个副本分片
	}
}
"

这个my-index索引将总共有3个主分片 + 3个副本分片 = 6个分片
```

## 索引的生命周期管理(ILM)

```
在实际应用中，数据是有生命周期的。例如，日志数据可能只需要保留最近7天的热数据，而更早的数据可以归档或删除。Elasticsearch 提供了索引生命周期管理 (ILM)功能来自动化这个过程。
ILM 定义了四个阶段：

1.热阶段Hot：索引正在被频繁地写入和查询。

2.温阶段Warm：索引通常只读，不再写入。

3.冷阶段Cold：索引很少被访问，但需要保留。查询速度可以慢一些。

4.冻结阶段(Frozen)：索引几乎不查询，冻结后索引元数据保留在内存里，但数据从节点缓存中删除，查询时需重新加载(性能差，但节省资源)

4.删除阶段Delete：索引不再需要，可以安全删除。

你可以通过策略（Policy）自动将索引在不同阶段之间迁移、滚动更新（Rollover）等。
```

### 生命周期策略(Policy)

```
定义索引在各阶段的行为和触发条件（如 “热阶段持续 7 天”“冷阶段后 30 天删除”）。
```



### 滚动索引(Rollover)

```
热阶段常用：当索引达到指定大小（如 50GB）或时间（如 24 小时）时，自动创建新索引，后续写入指向新索引（旧索引进入下一阶段）。
需配合索引别名（Alias）使用（如写操作指向 logs-write 别名，自动路由到最新索引）。
```



### 索引模板(Index Template)

```

```





# 映射(Mapping)

```
数据如何被存储和索引，直接影响到搜索的准确性、性能和功能。可以把它完全等同于关系型数据库中的表结构（Schema）。

映射是定义索引中文档结构的过程。它规定了文档包含哪些字段（Field），每个字段的数据类型（如 text, keyword, integer）以及这些字段如何被 Elasticsearch 处理（如是否被索引、是否存储原始值、使用什么分词器等）。

1.
定义数据类型：告诉 ES 字段 "123"是字符串还是数字，字段 "2023-10-27"是文本还是日期。

2.
控制索引行为：决定一个字段是否要被索引（用于搜索）、如何被分词。

3.
优化存储：选择合适的数据类型可以节省存储空间并提升性能。
```

## 倒排索引

```
正排索引（Forward Index）
逻辑：以 “文档” 为中心，记录每个文档包含的所有关键词。
文档1 → [Elasticsearch, 是, 一个, 搜索引擎]
文档2 → [搜索引擎, 需要, 倒排索引]

倒排索引（Inverted Index）
逻辑：以 “关键词” 为中心，记录每个关键词出现在哪些文档中（以及出现的位置、频率等）。
Elasticsearch → [文档1]
搜索引擎     → [文档1, 文档2]
倒排索引     → [文档2]

优势：查询 “搜索引擎” 时，直接定位到该关键词对应的文档列表，无需遍历所有文档，效率极大提升。
```

### 倒排索引的组成

```
1.词项词典（Term Dictionary）
 存储所有去重后的关键词（如 “Elasticsearch”“搜索引擎” 等）。
 为了加速查询，词典会按字母 / 拼音排序，并配合二分查找或哈希表快速定位词项。
2.倒排列表（Posting List）
 每个关键词对应一个倒排列表，记录包含该词的文档 ID，以及额外信息（可选）：
   词频（TF）：关键词在文档中出现的次数（影响相关性评分）。
   位置（Position）：关键词在文档中的具体位置（用于短语查询，如 “Elasticsearch 搜索引擎” 是否连续出现）。
   偏移量（Offset）：关键词在文档中的字符偏移（用于高亮显示搜索结果）。
   
搜索引擎 → [
  { doc_id: 1, tf: 1, positions: [3] },
  { doc_id: 2, tf: 1, positions: [0] }
]
```

### 倒排索引的工作流程

```
当你在 Elasticsearch 中执行全文搜索时（如查询 “搜索引擎”）：

1.分词（Tokenization）：ES 将查询语句拆分为关键词（如 “搜索引擎” 可能被拆分为 “搜索” 和 “引擎”，或作为整体，取决于分词器）。
2.查询词项词典：快速找到每个关键词对应的倒排列表。
3.合并结果：对多个关键词的倒排列表进行交集 / 并集运算（如 “搜索 AND 引擎” 取交集），得到符合条件的文档 ID。
4.相关性排序：根据词频（TF）、文档频率（DF）等因素计算文档相关性，返回排序后的结果。
```

## 字段数据类型

### 1.文本类型(Text)

```
text：
用途：用于全文检索的可变长字符串。如文章标题、产品描述、日志内容。
特点：值会被分析器（Analyzer） 分割成多个词条（Token）并建立倒排索引。你无法用 text字段做精确匹配和排序。


keyword：
用途：用于精确值匹配的字符串。如身份证号、邮箱地址、标签、状态码。
特点：值会被当作一个完整的词条存入索引，不会被分词。适合用于 term查询、排序、聚合。
最佳实践：一个字段同时拥有 text和 keyword子字段（Multi-fields）
```

#### 全文检索

```
使用全文搜索查询 "苹果 手机" 时，整个过程涉及分词、匹配、评分等多个步骤，最终返回符合条件的文档。
```

```
假设索引映射中 product_name 是 text 类型，使用中文分词器（如 IK 分词器），且有如下文档：

文档 1：product_name: "苹果 iPhone 15 手机"
文档 2：product_name: "华为手机 不是苹果"
文档 3：product_name: "小米平板 安卓系统"
文档 4：product_name: "苹果笔记本电脑"

1. 分词阶段（Query Analysis）
ES 首先对查询词 "苹果 手机" 进行分词处理（使用与 product_name 字段相同的分词器）：

分词结果：["苹果", "手机"]（IK 分词器会将中文拆分为有意义的词语）。
2. 匹配阶段（Matching）
ES 会在 product_name 字段的倒排索引中，查找包含 ["苹果", "手机"] 任意一词的文档：

包含 苹果 的文档：文档 1、文档 2、文档 4
包含 手机 的文档：文档 1、文档 2
最终匹配的文档：文档 1（含两词）、文档 2（含两词）、文档 4（含 “苹果”）
3. 相关性评分（Relevance Scoring）
ES 会根据 TF-IDF 算法 或 BM25 算法（默认）计算文档与查询的相关性，评分越高排名越靠前：

文档 1：同时包含 “苹果” 和 “手机”，且两个词都出现在商品名称中，相关性最高。
文档 2：同时包含两个词，但 “不是苹果” 可能降低相关性（语义稍弱），评分次之。
文档 4：只包含 “苹果”，不包含 “手机”，评分最低。
```

##### 例子

```
GET /products/_search
{
  "query": {
    "match": {
      "product_name": "苹果 手机"  // 对product_name字段执行全文搜索
    }
  }
}

#match 查询默认是 OR 逻辑，即包含任意一个关键词的文档都会被返回。如果需要 AND 逻辑（必须同时包含所有关键词），需显式指定：

"match": {
  "product_name": {
    "query": "苹果 手机",
    "operator": "and"  // 仅返回同时包含两词的文档（文档1、文档2）
  }
}
```

```
{
  "took": 5,  // 查询耗时（毫秒）
  "timed_out": false,  // 是否超时
  "hits": {
    "total": {
      "value": 3,  // 匹配到3个文档
      "relation": "eq"  // 精确计数
    },
    "max_score": 1.8,  // 最高评分
    "hits": [
      // 文档1：评分最高（同时包含两词）
      {
        "_index": "products",
        "_id": "1",
        "_score": 1.8,  // 相关性评分
        "_source": {
          "product_name": "苹果 iPhone 15 手机"
        }
      },
      // 文档2：评分次之
      {
        "_index": "products",
        "_id": "2",
        "_score": 1.2,
        "_source": {
          "product_name": "华为手机 不是苹果"
        }
      },
      // 文档4：评分最低（只含一词）
      {
        "_index": "products",
        "_id": "4",
        "_score": 0.5,
        "_source": {
          "product_name": "苹果笔记本电脑"
        }
      }
    ]
  }
}
```

#### 精确匹配

```
keyword 类型的查询核心是精确匹配，即只有当字段内容与查询词完全一致时，才会被匹配到。整个过程如下：

查询词不分词：
无论查询词是单个词还是短语（如 “苹果手机”），keyword 类型会将其视为一个完整的词项，不会进行分词处理。
直接匹配倒排索引：
keyword 字段的倒排索引中，存储的是完整的字段值（如 “苹果 iPhone 15” 作为一个整体词项）。查询时，ES 会直接在倒排索引中查找与查询词完全一致的词项，返回对应的文档。
无相关性评分（或评分固定）：
由于是精确匹配，匹配到的文档评分通常为 1.0（固定值），不存在类似 text 类型的相关性排序（因为要么匹配，要么不匹配）。
```

```
精确匹配是 keyword 类型最基础的用法，适用于需要严格匹配完整字段值的场景（如订单号、状态码、分类名称等）。
示例场景：
假设有一个 category 字段（keyword 类型），存储商品分类：

文档 1：category: "手机"
文档 2：category: "智能手机"
文档 3：category: "手机配件"
```

##### 例子

###### 精确匹配

```
使用 term 或 terms 查询（keyword 类型专用）：
// 精确匹配“手机”
GET /products/_search
{
  "query": {
    "term": {
      "category": "手机"  // 仅文档1会被匹配
    }
  }
}

结果说明：
只有 category 字段值完全等于 “手机” 的文档会被返回（仅文档 1）。
文档 2（“智能手机”）和文档 3（“手机配件”）不会被匹配，因为它们与查询词不完全一致。
```

###### 排序(Sorting)

```
对商品名称（product_name.keyword 子字段）按字母 / 汉字顺序排序。
GET /products/_search
{
  "sort": [
    { "product_name.keyword": "asc" }  // 按商品名称升序排列（A→Z，或汉字拼音顺序）
  ],
  "query": {
    "match_all": {}  // 匹配所有文档
  }
}
文档会按照 product_name 的完整值（如 “Apple iPhone 15”“华为 Mate 60”）的原始字符顺序排序。
若用 text 类型排序（"product_name": "asc"），ES 会报错，因为分词后的结果无法确定排序依据。
```

###### 聚合(Aggregation)

```
统计每个商品分类（category 字段）的商品数量。
GET /products/_search
{
  "size": 0,  // 不返回原始文档，只返回聚合结果
  "aggs": {
    "category_counts": {  // 聚合名称（自定义）
      "terms": {
        "field": "category",  // 基于category字段（keyword类型）聚合
        "size": 10  // 返回前10个分类
      }
    }
  }
}
返回每个分类的商品数量统计：
{
  "aggregations": {
    "category_counts": {
      "buckets": [
        { "key": "手机", "doc_count": 100 },  // “手机”分类有100个商品
        { "key": "电脑", "doc_count": 80 },   // “电脑”分类有80个商品
        { "key": "配件", "doc_count": 50 }    // “配件”分类有50个商品
      ]
    }
  }
}
```



### 2.数值类型(Numeric)

```
类型：long, integer, short, byte, double, float, half_float, scaled_float

选择原则：根据数值范围选择最节省空间的类型。例如，年龄用 byte（1-255）或 short就够了，无需用 long。
```

### 3. 日期类型 (Date)

```
用途：存储日期和时间。

特点：可以接受多种格式（如 "2023-10-27", "2023-10-27T12:00:00Z", 时间戳）。强烈建议指定格式。
```

### 4. 布尔类型 (Boolean)

```
boolean：接受 true或 false值
```

### 5. 对象与嵌套类型 (Object & Nested)

```
object：用于存储单个 JSON 对象（形成层次结构）。

示例： "user": { "first": "John", "last": "Doe" }

nested：用于存储对象数组，且需要数组中的对象彼此独立地进行查询。

解决什么问题？ object数组中的对象在底层是平铺存储的，查询时关联性会丢失。nested类型为数组中的每个对象创建独立的隐藏文档，解决了这个问题。

示例：博客文章的 comments（评论列表），你需要查询“用户A在2023年10月留下的所有评论”
```

### 6. 其他重要类型

```
geo_point：存储经纬度坐标（{"lat": 40.73, "lon": -73.98}），用于地理空间搜索。

ip：存储 IPv4 或 IPv6 地址。

completion：用于实现搜索自动补全（Suggest）功能
```

## 管理映射

```
方式1：动态映射-自动推断
未定义就直接插入文档，Elasticsearch 会自动根据 JSON 数据格式推测字段类型。
推测的类型可能不准确，后期修改成本高。不推荐用于生产环境

方式2：显式映射-手动定义
在写入数据之前，手动并明确地定义索引的映射。这是生产环境的最佳实践。

方式3：更新映射-有限更新
对于已存在的索引，映射可以添加新的字段，但绝对不能修改已有字段的类型（因为底层的数据存储方式已经确定）。
```

### 举例-手动定义和有限更新

```
创建一个 blog索引并指定完整的映射
curl -X PUT "localhost:9200/blog" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1
  },
  "mappings": { // 显式定义映射开始
    "properties": { // 定义文档的属性（字段）
      "title": {
        "type": "text", // 主字段为text，用于搜索
        "fields": { // 多字段配置
          "keyword": {
            "type": "keyword" // 子字段为keyword，用于精确匹配
          }
        }
      },
      "author": {
        "type": "keyword" // 作者名，精确匹配
      },
      "publish_date": {
        "type": "date",
        "format": "yyyy-MM-dd"
      },
      "content": {
        "type": "text" // 文章内容，全文搜索
      },
      "tags": {
        "type": "keyword" // 标签，精确匹配和聚合
      },
      "view_count": {
        "type": "integer" // 浏览量，用于范围查询和聚合
      },
      "is_published": {
        "type": "boolean" // 是否发布
      },
      "location": {
        "type": "geo_point" // 地理位置
      },
      "comments": { // 评论列表
        "type": "nested", // 使用nested类型保持数组对象的独立性
        "properties": {
          "user": {"type": "keyword"},
          "comment": {"type": "text"},
          "date": {"type": "date"}
        }
      }
    }
  }
}
'
为 blog索引添加一个新字段 new_field
curl -X PUT "localhost:9200/blog/_mapping" -H 'Content-Type: application/json' -d'
{
  "properties": {
    "new_field": {
      "type": "text"
    }
  }
}
'
```



# 一些问题

## 关于是否分词

```bash
字段在进行存储时，是否分词取决于字段的类型
keyowrd不进行分词
text进行分词

查询时，对查询的内容是否进行分词取决于DSL查询的类型
Match Query：分词
Match Phrase Query：分词
Term Query：不分词
Prefix Query：不分词
Wildcard Query：不分词
Query String/Simple Query String：这两个是封装器，根据是否带引号""来决定内部使用match(分词) 还是term/prefix(不分词)
```

