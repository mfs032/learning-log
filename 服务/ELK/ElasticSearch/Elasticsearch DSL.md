# ES查询语句

```
Elasticsearch DSL(Domain Specific Language)：ES原生的JSON查询语句
Elasticsearch SQL:ES提供了SQL接口，可以使用传统SQL语法进行查询
```

## Elasticsearch DSL

### 基本格式

```
所有的查询都包裹在query中，并通过_search API发送
```

```bash
curl -X GET "localhost:9200/<index_name>/_search" -H 'Content: application/json' -d'
{
	"query": {
		#具体的查询语句
	}
}
'
```



### 查询类型(两大类)

```
DSL查询主要分为两大类:叶子查询、符合查询
```

#### 1.叶子查询 (Leaf Queries)

```
直接在特定字段上查询特定值
```

##### match(全文模糊查询)

```bash
全文查询，会对查询内容进行分词，然后去匹配。建议在text字段使用
"query": {
	"match": {
		"title" : "Quick Brown Fox"
	}
}
```

##### match phrase(短语查询)

```bash
短语搜索，查询内容会被分词，但要求分词后的词项在索引中位置连续
#查询出的内容[quick][brown][fox]这三个词项在索引中的位置必须按顺序连续
"query" : {
	"match_phrase" : {
		"title" : "quick brown fox"
	}
}

#能查出"The quick brown fox jumps over the lazy dog"
#查不到"The quick dog, the lazy brown cat, the fox."
```



##### term(精确词项查询)

```bash
精确查询。查询的内容被视为一个整体，不经过分词器，推荐用于keyowrd字段
"query": {
	"term": {
		"status.keyword": "published"
	}
}

"query": {
	"term": {
		"status.keyword": {
			"value": "published"
			"boost": 2.0
		}
	}
}
```

##### terms

```bash
相当于SQL里的IN
"query": {
	"terms": {
		"tags": ["python", "java"]
	}
}
```

##### prefix(前缀查询)

```bash
查询的内容被视为一个整体，不经过分词器，直接用于前缀模式进行匹配
#匹配所有以sale开头的标签
"query" : {
	"prefix" : {
		"tags" : "sale"
	}
}
```



##### wildcard(通配符查询)

```bash
#查询tags中包含*code模式的文档，例如coupon_code 或者promo_code
"query" : {
	"wildcard" : {
		"tags" : {
			"value" : "*code"
		}
	}
}
```



##### range(范围查询)

```json
范围查询
"query": {
    "range": {
		"age": {
			"gte": 18,
			"lit": 30
		}
	}
}
```

##### exists/missing(存在性查询)

```bash
判断字段是否存在
"query" : {
	"exists" : {
		"field" : "start_date"
	}
}
```

##### regexp(正则表达式查询)

```bash
"query" : {
	"regexp" : {
		"product_id" : "B[0-9]{3}"
	}
}
```





#### 2.复合查询(Compound Queries)

```
将其他叶子查询或复合查询组合起来，形成更复杂的逻辑
bool：最常用、最强大的复合查询。可以组合多个子查询之间的逻辑关系。
must：必须匹配，贡献得分 (AND)
should：应该匹配，贡献得分 (OR)
must_not：必须不匹配，不贡献得分 (NOT)
filter：必须匹配，但不贡献得分，性能更高，常用于过滤。
```

```yaml
"query": {
  "bool": {
    "must": [
      { "match": { "title": "apple" } }
    ],
    "must_not": [
      { "term": { "tags": "news" } }
    ],
    "filter": [
      { "range": { "view_count": { "gt": 100 } } }
    ]
  }
}
```



## ES查询DSL

```json
{
  // ****** 1. 文档控制参数 ******
  "track_total_hits": false,
  "sort": [ ... ],
  "fields": [ ... ],
  "size": 500,
  "version": true,
  "script_fields": {},
  "stored_fields": [ "*" ],
  "runtime_mappings": {},
  "_source": false, // <-- 关键参数
  
  // ****** 2. 核心查询和过滤 ******
  "query": {
    "bool": {
      "must": [ ... ],
      "filter": [ ... ],
      "should": [],
      "must_not": []
    }
  },
  
  // ****** 3. 显示/优化参数 ******
  "highlight": { ... }
}
```

### 1.文档控制参数

```bash
size:控制返回的文档数量，如果是聚合查询此值应置为0

sort:定义搜索结果的排序方式，Kibana默认使用@timestamp降序(desc)排序

track_total_hits:控制命中总数的计算。ES在执行查询时，不会精确计算所有匹配文档的总数，而是返回一个近似值，例如10000并附带relation: "gte"表示至少有10000条。该参数可以强制ES精确计算并返回总匹配数默认值是false，即不计算总数返回ES优化后的近似值
track_total_hits:true可以强制计算搜索匹配文档的总数，无论数量多少
track_total_hits:10000表示精确计算前10000条匹配结果的总数，如果实际匹配数超过10000，则返回10000并标记为近似值(relation: "gte")

_source:控制是否返回原始文档源，false意味着不反悔完整的JSON文档，只返回在fields中指定的字段，优化网络传输

fields：指定要反悔的字段列表，结合_source: false使用

script_fields:运行时计算字段，允许用户在查询结果返回之前，对文档中的一个或多个字段进行运行时计算、转换或修改，并将计算结果作为一个新的字段返回，相当于一个脚本，能耗高，不推荐使用

stored_fields:["*"]表示返回所有可存储的字段，与_source: false结合使用。可以将字段的值存储到索引中，这与_source字段分开，如果快速检索这些字段的值，而不去解析庞大的_source字段，可以使用该字段

version:返回文档的版本号，这是Kibana进行并发控制和更新视图所必须的。ES会给每个文档维护一个版本号，每次文档被修改，版本号递增。刷新discover视图时返回的是最新的版本号
```

### 2.核心查询和过滤(query对象)

```bash
#使用bool查询组合各种条件
must：必须满足条件，AND逻辑，参与评分
filter:必须满足条件，AND逻辑，不参与评分
should:字面意思，OR逻辑，参与评分
must_not：必须排除，NOT逻辑，不参与评分
```

### 3.显示优化参数(highlight)

```bash
highlight：配置搜索结果中的关键词高亮
```

### 示例

```json
{
  "track_total_hits": false,
  "sort": [
    {
      "@timestamp": {
        "order": "desc",
        "unmapped_type": "boolean"
      }
    }
  ],
  "fields": [
    {
      "field": "*",
      "include_unmapped": "true"
    },
    {
      "field": "@timestamp",
      "format": "strict_date_optional_time"
    }
  ],
  "size": 500,
  "version": true,
  "script_fields": {},
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "_source": false,
  "query": {
    "bool": {
      "must": [],
      "filter": [
        {
          "range": {
            "@timestamp": {
              "format": "strict_date_optional_time",
              "gte": "2025-10-13T06:10:42.786Z",
              "lte": "2025-10-13T06:25:42.786Z"
            }
          }
        },
        {
          "match_phrase": {
            "tdcDomain": "mdc.iweq1ddc.com"
          }
        }
      ],
      "should": [],
      "must_not": []
    }
  },
  "highlight": {
    "pre_tags": [
      "@kibana-highlighted-field@"
    ],
    "post_tags": [
      "@/kibana-highlighted-field@"
    ],
    "fields": {
      "*": {}
    },
    "fragment_size": 2147483647
  }
}
```



## ES DSL的响应

```json
{
  "took": 15,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 2,
      "relation": "eq"
    },
    "max_score": 1.3862944,
    "hits": [
      {
        "_index": "my-index",
        "_id": "1",
        "_score": 1.3862944,
        "_source": {
          "title": "Introduction to Elasticsearch",
          "author": "John Doe",
          "tags": ["technology", "search"],
          "content": "This is a guide about ES.",
          "publish_date": "2023-10-27",
          "view_count": 150
        }
      },
      {
        "_index": "my-index",
        "_id": "2",
        "_score": 0.8754687,
        "_source": {
          "title": "Another Article",
          "author": "Jane Smith",
          "tags": ["technology"],
          "content": "This article also mentions Elasticsearch.",
          "publish_date": "2023-10-26",
          "view_count": 50
        }
      }
    ]
  }
}
```

### 各部分描述

#### 1.元信息层

```
元信息层
描述查询执行的整体情况
took: 15
	查询执行的总时间，单位毫秒
time_out: false
	查询是否超时

_shards: {...}
	描述查询涉及的分片(Shards)的统计信息
	total: 1
		查询要执行的分片数
	successful: 1
		查询成功的分片数
	skipped: 0
		由于某些原因被跳过的分片数
	failed: 0
		查询失败的分片数
	
```

#### 2.核心结果层(hits)

```
实际的搜索结果。
hits.total: { "value": 2, "relation": "eq" }
	含义：匹配查询条件的文档总数。
		value: 2- 匹配到的文档数量。
		relation: "eq"- 表示 value是准确值 (eq代表 equal)。如果总数很大，为了提升性能，ES 可能会返回一个近似值，此时 relation会是 "gte"(greater than or equal to)。
		
hits.max_score: 1.3862944
	含义：所有匹配文档中的最高相关性得分 (_score)。如果查询使用了 filter上下文或不计算分数，此值为 null。
	
hits.hits: [...]
	含义：一个数组，包含了当前“页”的实际匹配文档。默认返回前10条。数组中的每个对象代表一个文档。
```

#### 3.文档层

```
_index: "my-index"
	含义：该文档所属的索引名称。

_id: "1"
	含义：该文档的唯一标识符 (ID)。

_score: 1.3862944
	含义：该文档与查询的相关性分数。分数越高，匹配度越好。在 filter上下文或使用 constant_score查询时，分数是统一的（如 1.0 或 0）。

_source: {...}
	含义：这是最重要的字段，包含了你在索引时提供的原始 JSON 文档内容。
	用途：应用程序所需的数据几乎都从这里提取。你可以通过在查询中设置 "_source": false来不返回它，或者使用 _source_includes和 _source_excludes来过滤返回的字段。
```



