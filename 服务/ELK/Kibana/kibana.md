---
typora-root-url: ./
---

# Kibana的data view

```bash
在Kibana中创建一个data view需要如下字段
Name数据视图的名字
Index pattern索引模式，用来匹配sources，一个数据视图可以匹配到多个sources

例如一个叫logs-all-default的数据视图，索引模式是logs-*-default，则可以匹配到多个索引(源)，例如logs-apk-default、logs-cdn-default、logs-web-default
```

# Kibana顶部导航栏

![Kibana顶部导航栏](/img/Kibana顶部导航栏.png)

```
主菜单按钮(左侧三条横线)
Discover是当前所在的应用程序
New：清楚当前所有查询条件，开始一个新的会话
Open：打开已保存的搜索，通过Save按钮保存搜索
Share：共享视图
Inspect：检查查询，显示Kibana在后台向ES发送的原始查询请求(JSON)以及ES返回的原始响应
Save：保存当前的查询和视图状态
```



## 主菜单按钮

![Kibana主菜单按钮](/img/Kibana主菜单按钮.png)

```bash
菜单被分为Recently viewed、Analytics(分析)、Management(管理)
Home：主页
Recently viewed：最近查看

#Analytics：分析，用于搜索和展示数据
Discover：查看查询原始文档
Dashboard：将多个可视化图标组织在一个视图中，用于监控数据和趋势分析
Canvas：画布，创建基于数据的图表用于PPT
Maps：用于可视化地理空间数据，用于地图展示和分析
Visualize Library：可视化库，创建单个可视化图表，例如柱状图、饼图、折线图，用来保存并添加到仪表盘中

#Management：管理，用于配置维护Kibana和ES资源的后台工具
Dev Tools：开发工具，提供一个可以直接和ES进行交互的Console(控制台)，编写执行REST API请求
Stack Management：堆栈管理，一个大集合，包含对整个ELK Stack的配置和维护

```

## Save按钮

![Save按钮](/img/Save按钮.png)

```
可以将当前的查询保存
Title：名称
Description：描述
Tags：标签，例如业务部门
Store time with saved search：开启后，当前选定的时间范围也会被保存到这个搜索中
```

## Inspect按钮

![Inspect按钮](/img/Inspect按钮.png)

```bash
Request是指发送的请求，这里有两个
Statistics：是统计信息
Request：是Kibana发送的完整的JSON请求体
Response：是Kibana收到的完整的JSON响应体
```

# discover

## Kibana第二行导航栏

![第二行导航栏](/img/第二行导航栏.png)

### 数据视图

```
选择的数据视图，数据视图通过创建是指定的索引模式匹配源
```

### 过滤

```
添加filter
```



### 查询语句

```
可以使用KQL或者Lucene语句查询
```



### 界定时间和刷新

```
字面意思
```

## Kibana第三行

![Kibana第三行](/img/Kibana第三行.png)

### 图表

```
柱状图是查询结果聚合的图像，Kibana会发送两个JSON查询，一个查询文档本身，一个用来聚合查询的结果
```

### document

```
查询到的文档会以表格的形式展示
```

### field statistics

![field statistics](/img/field statistics.png)

```
提供各个字段的概览
```

# visualize library(可视化库)

![visualize library](/img/visualize library.png)

```bash
Visualizations (可视化)：显示所有已创建和保存的可视化图表，可在该页面搜索编辑删除现有的图表
Annotation groups(标注组)：用于管理和组织标注的功能区，一般给时间序列图表上添加标记，例如系统升级，大规模宕机，用于解释图表中异常行为发生的原因
```

## create visualization

![new visualization](/img/new visualization.png)

```
推荐和智能工具
Lens：可视化编辑器
Maps：地理空间分析工具

高级和专业工具
TSVB：时间序列高级分析工具
Custom visualization：自定义可视化工具

经典方法
Aggregation based：传统Kibana可视化编辑器
Explore options：显示所有经典的图表类型列表

杂项工具
Text：文本和图像工具，允许用户向Dashboard添加纯文本
```

## 图类型

```
柱状图：
垂直柱状图：Bar vertical
堆叠垂直柱状图：Bar vertical stacked
百分比柱状图：Bar vertical percentage

面积图：
基础面积图：Area
堆叠面积图：Area stacked
百分比面积图：Area percentage

线图：Line
```

## Len可视化编辑器

![Len可视化编辑器](/img/Len可视化编辑器.png)

```
Horizontal axis定义图表的X轴
Vertical axis定义图表的Y轴
Breakdown分组：用于将图表拆分为不同的部分
Add layer：在现有可视化之上添加另一个数据图层，例如在线图上叠加一个柱状图
```

### 纵轴

![Len编辑器-纵轴](/img/Len编辑器-纵轴.png)

```
Date historam：Intervals的一种
Intervals(间隔聚合)：将连续的数值或时间数据划分成等效连续的区间。设置一个固定间隔如1h或者100，ES将数据放入相应桶中


Top values(Top值聚合)：将数据按照某个字段的唯一值进行分组，并只返回出现频率最高的N个值，适用于keyword、text字段的分词、数值等。统计字段中每个唯一值出现的次数，然后根据用户设定的size参数，返回排名靠前的桶。
非时间相关系数需要关闭 Show current time marker


Filters(过滤器聚合)：根据用户预先定义好的过滤条件来创建桶，使用任何字段。用户提供查询语句(过滤器)，数据被分成不同的桶，每个桶包含满足响应查询语句的文档，文档可以落入多个桶
```

### 横轴

![Len编辑器横轴](/img/Len编辑器横轴.png)

#### 1.基础统计函数

```bash
Count：计数，计算每个分组中文档总数，使用Records(记录总数)
Average：计算指定字段值的平均数，数值字段
Minimum：找出字段最小值，数值字段
Maximum：找出字段值最大值，数值字段
Sum：计算指定字段总和，数值字段
Unique count：唯一计数，计算指定字段的不重复的数量，任何字段
```

#### 2.分布和离散度函数

```bash
Median：中位数，找出指定字段的中位数，数值字段
Percentile：百分位，计算指定字段值的任意百分位，例如第90百分位找出90%的相应时间是多少，数值字段
Percentile rank：百分位排名，找出指定字段值在整个数据集中所处的百分比排名，数值字段
Standard deviation：计算指定字段的标准偏差，用于衡量数据的离散程度，数值字段
```

#### 3.高级时序分析函数

```bash
Counter rate：计数率，计算技术随时间变化的变化率，例如每秒的请求书，Records或数值字段
Cumulative sum：累计总和，计算时间累加的总和，用于计算一段时间内总流量或总错误数，Recocrds或数值字段
Differences：差异，计算当前时间点与之前时间点的值的差异，常用于计算增量或环比变化
Last value：上一个值，返回时间序列中最后一个有值的点的值，任意字段
Moving average：移动平均，计算随时间变化的平滑平均值，用于消除短期波动，展示长期趋势，根据公式计算，Records或数值字段
```



### breakdown(分组)

```
定义图表的副维度
将主维度中的没哟个桶进一步细分，即创建子桶，本质上还是创建桶，所以配置的逻辑和横轴的配置是相同的
```

