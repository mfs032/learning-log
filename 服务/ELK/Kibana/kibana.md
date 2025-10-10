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

