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

##### match

```bash
全文查询，会对查询进行分词，然后去匹配。建议在text字段使用
"query": {
	"match": {
		"title": "Quick Brown Fox"
	}
}
```

##### term

```bash
精确查询。用于匹配未经分词的精确值(如keyword字段)
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

##### range

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

##### exists/missing

```
判断字段是否存在
```



#### 2.符合查询(Compound Queries)

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



