# 服务网格

```bash
服务间通信的基础设施层。
单体应用不同服务可以通过函数调用进行通信
微服务中，不同服务进程需要通过网络进行远程调用，引入一系列问题：服务发现，负载均衡，容错，流量的可观测性。
```

## 服务网格的架构

```
所有服务网格(Istio，Linkerd)都遵循类似的两层架构：数据平面 + 控制平面

1.数据平面
由所有Sidecar代理组成的网络，是数据包实际流动的地方
职责：
	接管流量：连接并处理所有服务间的流量
	执行策略：实施路由规则、安全策略、访问控制
	收集数据：生成指标、日志、追踪信息
常见组件：
	Envoy(Istio、App Mesh使用)、Linkerd2-proxy(Linkerd使用)
	
2.控制平面
管理数据平面，不处理数据包
职责：
	配置管理：从运维人员接受指令，并转换为Sidecar能理解的配置，然后下发到所有代理
	证书管理：为每个服务签发身份证书，用于服务间的安全通信
	服务发现：知晓集群中所有服务及其实例的位置
常见组件：
	Istiod(Istio)、Linkerd Destination(Linkerd)


复杂性：引入了一个新的、复杂的基础设施层，学习曲线陡峭。
资源开销：每个 Pod 都增加了一个代理容器，会消耗额外的 CPU 和内存。
延迟：由于流量需要经过额外的代理，会引入微小的网络延迟（通常在毫秒级以下）。
```

## Sidecar模式

```
将通信治理功能从应用程序中抽离出来，作为一个独立的进程，与每个服务实例一起部署。
这个独立的进程就是一个轻量级网络代理，被称为 Sidecar（边车）。

工作模式：
1.部署时，系统会自动注入一个 Sidecar 代理容器（如 Envoy）到同一个 Pod 中。

2.Pod 内所有进出订单服务的网络流量，都被透明地劫持，先经过 Sidecar 代理，再由 Sidecar 代理转发到目标服务的 Sidecar。

3.所有聪明的逻辑（服务发现、负载均衡、熔断等）都在 Sidecar 中实现，业务代码对此完全无感知。

所有服务都部署了 Sidecar 后，这些 Sidecar 相互连接，就形成了一张专用的通信层——这就是“服务网格”这个名字的由来。服务网格就是由这些 Sidecar 代理组成的网络。
```



# 部署Istio后新增的核心资源

```
1.新增命名空间:istio-system
这是Istio控制平面组件居住的系统命名空间，类似kube-system
```



```
2.istio-system命名空间新增的资源
（1）新增pod(容器进程)
kubectl get pod -n istio-system
# 典型输出示例：
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-5dc9785d74-abcde    1/1     Running   0          5m
istio-ingressgateway-7fcdffd8fd-fghij   1/1     Running   0          5m
istiod-6b5d5dbd9c-klmno                  1/1     Running   0          5m

istiod-xxxx：控制平面，负责配置下发、证书管理、服务发现，必须存在
istio-ingressgateway-xxx：入口网关，接受所有从集群外部进入的流量，不是必须存在
istio-egressgateway-xxxx：出口网关，控制所有从集群内部流向外部服务的流量，不是必须的

（2）新增dep
kubectl get deployments -n istio-system
# 典型输出示例：
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
istio-egressgateway    1/1     1            1           5m
istio-ingressgateway   1/1     1            1           5m
istiod                 1/1     1            1           5m
对应3个pod的dep，确保对应的pod始终运行并保持所需要的副本数

（3）新增svc
kubectl get services -n istio-system
# 典型输出示例：
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.96.100.10    <none>          80/TCP,443/TCP                                                               5m
istio-ingressgateway   LoadBalancer   10.96.100.201   123.45.67.89     15021:30690/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15443:30835/TCP   5m
istiod                 ClusterIP      10.96.100.11    <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP    
这三个svc给对应的pod提供稳定的网络访问模式

istio-ingressgatewayService：它的类型是 LoadBalancer。如果是在云平台上，EXTERNAL-IP会是一个公网 IP（如 123.45.67.89）。这个 IP 就是你整个集群流量的总入口！
istiodService：类型是 ClusterIP，供集群内的 Sidecar 连接，以获取配置和证书
```

```
3.业务命名空间发生的变化
给一个命名空间（比如 default）打上标签后，再部署应用
# 给命名空间打标签，启用 Sidecar 自动注入
kubectl label namespace default istio-injection=enabled

# 然后部署你的应用，例如官方的 Bookinfo
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get pods

# 输出示例：
NAME                             READY   STATUS    RESTARTS   AGE
productpage-v1-xxxxx             2/2     Running   0          1m   # <-- 注意这里是 2/2！
reviews-v1-xxxxx                 2/2     Running   0          1m
reviews-v2-xxxxx                 2/2     Running   0          1m
details-v1-xxxxx                 2/2     Running   0          1m

READY列从通常的 1/1变成了 2/2
每个业务 Pod 里都多了一个容器：
容器 1：你的业务容器（如 productpage）。
容器 2：istio-proxy容器，也就是 Sidecar。这就是 Istio 的数据平面！
```



# 请求路由

```bash
VirtualService(VS)：定义路由规则。规定如何根据特定的属性(如URI、头信息、权限等)将流量发送到不同的服务实例
DestinationRule(DR)：定义可用服务的子集和策略。在VirtualService将流量路由给一个服务后，DestionationRule定义了该服务有哪些版本(子集)，以及应用于这些子集的策略(如负载均衡、连接池设置)
```



```
以bookinfo应用为例，它包含四个微服务
productpage： 产品页面，会调用 details和 reviews服务。
details： 图书详情信息。
reviews： 书评服务。它有三个版本：
	v1： 不调用评分服务，不显示星级。
	v2： 调用 ratings服务，显示黑色星级。
	v3： 调用 ratings服务，显示红色星级。
ratings： 评分服务。

控制访问 reviews服务的流量，将其路由到不同的版本。
```

## 使用DestionationRule定义服务子集

```yaml
#使用DestionationRule定义服务子集
# destination-rule-reviews.yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews # 指向 Kubernetes 中的 reviews Service
  subsets:
  - name: v1 # 定义子集 v1
    labels:
      version: v1 # 选择标签为 version: v1 的 Pod
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3
      
#应用这个配置，Istio就会知道reviews服务有三个可用子集
```

## 使用VirtualService定义路由规则

### 基于权重的流量切分(金丝雀发布)

```yaml
#使用VirtualService定义路由规则
#基于权重的流量切分(金丝雀发布)
# virtual-service-reviews-canary.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 90 # 90% 的流量去往旧版本 v1
    - destination:
        host: reviews
        subset: v2
      weight: 10 # 10% 的流量去往新版本 v2（金丝雀）
```

### 基于用户身份的路由(A/B测试)

```yaml
# 基于用户身份的路由(A/B测试)
# virtual-service-reviews-ab-test.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match: # 匹配条件：如果请求头中包含 "user-id: test-user"
    - headers:
        user-id:
          exact: test-user
    route: # 满足上述条件的请求，路由到 v3
    - destination:
        host: reviews
        subset: v3
  - route: # 不满足上述条件的所有其他请求，默认路由到 v1
    - destination:
        host: reviews
        subset: v1
      weight: 100
```

### 基于URI路径的路由

```yaml
# virtual-service-reviews-path.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match: # 匹配条件：如果请求路径以 /api/v2/ 开头
    - uri:
        prefix: /api/v2/
    route: # 满足条件的请求，路由到 v2
    - destination:
        host: reviews
        subset: v2
  - match: # 匹配条件：如果请求路径以 /api/v3/ 开头
    - uri:
        prefix: /api/v3/
    route: # 满足条件的请求，路由到 v3
    - destination:
        host: reviews
        subset: v3
  - route: # 默认路由
    - destination:
        host: reviews
        subset: v1
      weight: 100
```

## 路由规则的优先级与匹配顺序

```
在 VirtualService中，可以定义多个 http路由块。它们的匹配顺序是从上到下的。
当一个请求进入时，Istio 会按顺序检查 http块中的 match条件。
一旦匹配到第一个规则，就会执行该规则对应的操作（如 route, redirect, rewrite），并且停止后续规则的匹配。
最后一条规则通常是不带 match条件的“默认”路由规则。


完整的路由流程总结
请求发起：productpage服务试图调用 reviews服务。
Sidecar 拦截：请求被 productpagePod 内的 istio-proxy(Envoy) Sidecar 拦截。
规则匹配：Sidecar 查询已下发的 VirtualService配置，根据请求的头部、路径等属性匹配路由规则。
确定目标子集：根据匹配到的规则，确定目标服务的子集（例如 reviews服务的 v2子集）。
服务发现：Sidecar 查询 DestinationRule和服务的 Endpoints，获取属于 v2子集的所有健康 Pod 的 IP 地址列表。
负载均衡：根据 DestinationRule中定义的负载均衡策略（如轮询），从列表中选择一个目标 Pod IP。
请求转发：Sidecar 将请求直接转发到选中的目标 Pod。目标 Pod 的 Sidecar 接收请求，再交给业务容器处理。
```



# 故障恢复

## 主要故障恢复功能

```
VirtualService:
	超时：防止服务长时间等待无响应的后端，快速失败。
	重试：处理短暂的网络抖动或后端实例临时不可用。
	故障注入：主动在系统中引入故障，以测试整个系统的韧性和监控告警是否有效。
DestionationRule：
	熔断器：当某个服务实例或版本连续失败时，暂时停止向其发送请求，防止资源耗尽和故障扩散。
```

### 超时

```yaml
#工作原理：如果对上游服务的请求在指定时间内没有收到响应，Sidecar 代理将主动失败该请求，并向客户端返回一个 HTTP 504（网关超时）错误。
#目的：释放客户端资源，避免请求线程被长时间占用，实现快速失败。
#假设 productpage服务调用 reviews服务。我们希望为这个调用设置 5 秒的超时。
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
    # 故障恢复配置开始
    timeout: 5s # 设置 5 秒超时
    # 故障恢复配置结束
```

### 重试

```yaml
#重试用于处理瞬时性故障
#工作原理：当一次请求失败（如由于超时或服务器返回 5xx 错误）时，Sidecar 代理会自动尝试将请求重新发送到另一个健康的后端实例。
#目的：提高请求的最终成功率，对用户透明。
#在超时的基础上，为 productpage到 reviews的调用增加重试策略。
#重试会增加后端的负载，尤其当后端服务已经压力很大时。因此要谨慎设置重试次数，并且对于 非幂等 操作（如下单、支付）要特别小心，通常不应重试。
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
    timeout: 5s
    # 故障恢复配置开始
    retries:
      attempts: 3    # 最多重试 3 次（初始请求 + 3次重试 = 最多4次尝试）
      perTryTimeout: 2s # 每次重试尝试的超时时间
      retryOn: 5xx,gateway-error,connect-failure,reset # 在什么情况下重试
    # 故障恢复配置结束
```

### 故障注入

```yaml
#在 VirtualService中配置规则，故意在流量中引入故障（如延迟或错误）。
#目的：1、验证故障恢复机制（超时、重试、熔断）是否按预期工作。2、确保监控和告警系统有效。
#向访问 reviews服务的流量中注入 5 秒的延迟
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - fault: # 故障注入配置
      delay:
        percentage: 
          value: 100 # 100% 的请求都会注入延迟
        fixedDelay: 5s # 固定延迟 5 秒
    route:
    - destination:
        host: reviews
        subset: v1
        
#-------------------       
#也可以注入http状态码
fault:
  abort:
    percentage:
      value: 50 # 50% 的请求会返回错误
    httpStatus: 500 # 返回 500 内部服务器错误
```



### 熔断器

```yaml
#熔断器是防止故障蔓延和级联失败
#工作原理：Sidecar 代理会持续监控到某个服务子集（或特定实例）的请求成功率。当失败率超过阈值时，熔断器会“跳闸”，在接下来的一段时间内，立即拒绝所有发往该后端的请求，而不是真正发送出去。
#目的：
#快速失败：让客户端快速感知到下游故障，而不是等待超时。
#给后端恢复时间：切断流量，为故障后端提供恢复机会。
#防止雪崩：避免客户端资源因不断重试故障后端而耗尽。
#效果：如果在 30 秒内，到某个 reviews v1实例的连续错误达到 10 次，该实例将被“熔断” 30 秒，期间所有发往它的请求会立即失败。30 秒后，会放一个请求尝试探测其是否恢复。
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  # 故障恢复配置开始
  trafficPolicy: # 定义连接到 reviews 服务的默认策略
    connectionPool: # 连接池设置，是熔断的基础
      tcp:
        maxConnections: 100 # 到 reviews 服务所有实例的最大并发连接数
      http:
        http1MaxPendingRequests: 1000 # 等待处理的最大 HTTP 请求数（队列长度）
        maxRequestsPerConnection: 10 # 每个连接的最大请求数
    outlierDetection: # 异常点检测，即熔断器逻辑
      consecutive5xxErrors: 10 # 连续发生 10 次 5xx 错误
      interval: 30s            # 在 30 秒的时间窗口内统计
      baseEjectionTime: 30s   # 首次弹射（熔断）的持续时间
      maxEjectionPercent: 50  # 最多可将 50% 的 hosts 实例弹出
  # 故障恢复配置结束
```



# 入口网关

```
Istio 入口网关是一个运行在网格边缘的负载均衡器，它是外部流量进入服务网格的唯一入口。
	本质：它是一个特殊的 Pod，内部运行着与数据平面相同的 Envoy 代理，但这个代理被配置为只处理进入网格的流量（南北向流量）。

作用
	统一入口管理：为整个网格提供一个稳定、统一的公网入口 IP 地址。
	功能强大：提供了比传统 Ingress（如 Nginx）更强大、更精细的 L4/L7 路由能力，并且可以与网格内部的安全策略（如 JWT 认证、mTLS）无缝集成。
	端到端可观测性：因为入口网关是 Istio 数据平面的一部分，所以从网关开始的整个请求链路（从外部用户到最内部的服务）都可以被追踪、监控，实现了真正的端到端可观测性。
	协议支持广泛：原生支持 HTTP, HTTPS, gRPC, TCP, TLS 等协议，而传统 Ingress 对非 HTTP 协议的支持通常较弱。
	
核心组件：
Gateway和VirtualService
	Gateway： 定义“端口和协议”。它配置的是网关本身，指定网关监听哪些端口、使用什么协议以及 TLS 证书等。它解决的是“网关能接收什么类型的流量”的问题。
	VirtualService： 定义“路由规则”。它将进入网关的流量，根据主机名、路径等规则，路由到网格内的具体服务。它解决的是“接收到的流量应该被发送到哪里去”的问题。
```

## 示例

```yaml
#创建Secret存储TLS证书
apiVersion: v1
kind: Secret
metadata:
  name: bookinfo-tls-cert
  namespace: istio-system # 通常证书放在网关所在的命名空间
type: kubernetes.io/tls
data:
  tls.crt: <你的证书Base64编码>
  tls.key: <你的私钥Base64编码>
```

```yaml
#定义Gateway
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway # 选择器，确定这个配置由哪个网关Pod实例处理
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE # 启用TLS终止
      credentialName: bookinfo-tls-cert # 引用上面的证书Secret
    hosts:
    - bookinfo.example.com # 该配置仅适用于此主机名
```

```yaml
#定义VirtualService
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo-vs
spec:
  hosts:
  - bookinfo.example.com # 匹配的目标主机，必须出现在Gateway的hosts列表中
  gateways:
  - bookinfo-gateway # 关键：指定这个路由规则绑定到哪个Gateway上
  http:
  - match:
    - uri:
        exact: /productpage # 路径匹配规则
    route:
    - destination:
        host: productpage.default.svc.cluster.local # 网格内部服务名
        port:
          number: 9080
```



## 流量路径

```
阶段一：流量进入集群(南北流量)
1.用户发起请求
	用户在浏览器输入网址
2.DNS解析
	浏览器查询DNS服务器，域名被解析为istio-ingressgatewayService的External IP，这个External IP就是云厂商负载均衡器的公网IP

3.到达云负载均衡器
	这个云负载均衡器是istio-ingressgateway德LoadBalancer类型德svc
	
4.负载均衡器将流量转发到节点
	负载均衡器将流量转发到集群中某个运行istio-ingressgatewayPod节点的特定端口(NodePort)

5.kube-proxy接入
	节点上的kube-proxy根据iptables/ipvs规则将请求负载均衡到该节点或者其它节点上的istio-ingressgatewayPod

阶段二：入口网关处理(istio规则生效)
6.istio-ingressgatewayPod处理请求：
	请求进入istio-ingressgatewayPod，被Envoy代理拦截
	Envoy根据已下发的配置(来自istiod)
		（1）Gateway资源：监听对应端口，例如443，并对 bookinfo.example.com使用特定的 TLS 证书进行 TLS 终止（解密），
		（2）VirtualService资源：对于主机 bookinfo.example.com且路径为 /productpage的请求，应路由到 productpage服务的 9080 端口。
	网关现在知道目标了：集群内的 productpage.default.svc.cluster.local:9080
	
阶段三：服务间通信(东西向流量)
7.入口网关转发流量到porductpage服务：
	istio-ingressgateway的 Envoy 代理需要将请求发送给 productpage服务的一个 Pod。它不是简单地向 Service 的 ClusterIP 发送请求，而是：
		查询 productpage服务的 Endpoints 列表（健康的 Pod IPs）。
		根据相关的 DestinationRule中定义的负载均衡策略（如轮询），选择一个目标 Pod IP。
		直接建立连接到该 Pod IP。
		
8.请求到达productpagePod的Sidecar：
	请求首先到达选中的 productpagePod 的 istio-proxy（Sidecar）容器。
	Sidecar 进行一系列操作：
		服务间身份验证：与对端（入口网关）进行 mTLS 握手，确保通信安全。
		执行策略：检查是否有适用于此服务的策略（如速率限制）。
		收集遥测数据：记录指标和访问日志。

9.Sidecar将请求交给业务容器
	Sidecar 将解密后的明文 HTTP 请求转发给同在一个 Pod 内的 productpage业务容器。
	
10.productpage业务逻辑处理
	productpage容器处理请求。为了生成页面，它需要调用 reviews服务来获取评论信息。
	业务代码发起一个简单的内部 HTTP 请求：http://reviews:9080/reviews。
	
阶段四：内部服务调用(东西流量)
11.出站请求被 Sidecar 拦截：
	这个从 productpage容器发往 reviews服务的请求，并没有真正离开 Pod。它被同一个 Pod 内的 istio-proxySidecar 再次拦截。

12.Sidecar 进行服务发现和负载均衡：
	productpage的 Sidecar 查询 reviews服务的 Endpoints。
	它根据为 reviews服务配置的 VirtualService和 DestinationRule（例如，将 90% 的流量发给 v1，10% 发给 v2），选择一个目标 reviewsPod。
	直接建立连接到目标 reviewsPod 的 IP。

13.请求到达 reviewsPod 的 Sidecar：
	重复步骤 8 和 9：请求先经过 reviewsPod 的 Sidecar（进行 mTLS、收集遥测），然后被转发给 reviews业务容器。

14.reviews服务响应：
reviews容器处理请求并返回评论数据。响应沿着原路返回：reviews容器 -> reviewsSidecar -> productpageSidecar -> productpage容器。

阶段五：响应返回用户
15.最终响应返回：
	productpage容器组装好完整的 HTML 页面。
	响应路径与请求路径完全相反：productpage容器 -> productpageSidecar -> istio-ingressgatewayPod -> 云负载均衡器 -> 用户浏览器。
```

# 外部服务

## 服务发现

```
Istio默认只信任和管理它已知的、在 Kubernetes 服务注册中心（即 Kubernetes API Server）里注册过的服务。

在纯粹的 Kubernetes 环境中，服务发现是这样工作的：
当你创建一个 Service资源时，Kubernetes 会将其注册到 API Server 中。
kube-proxy会监听这些 Service的变化，并更新本地的 iptables/ipvs规则，实现负载均衡。
简单应用通过 DNS 解析（如 myservice.default.svc.cluster.local）来找到服务。

Istio 在此基础上进行了增强：
Istio 的控制平面（istiod）会持续监听（Watch）Kubernetes API Server，获取集群内所有 Service和 Endpoints（Pod IP 列表）的信息。
istiod将这些来自 Kubernetes 的“原始”服务信息，转换并下发 给网格内的每一个 Sidecar 代理（Envoy）。
因此，每个 Sidecar 都拥有一份完整的、实时的内部服务清单。
所以，对于在 Kubernetes 内创建的服务，Sidecar 天生就知道它们的存在。
```

## ServiceEntry的作用

```
当调用外部服务时会发生什么？（没有 ServiceEntry 的情况）
假设你的 Pod 内的应用代码试图访问 https://api.github.com/users。
应用发起调用：你的业务代码使用标准库（如 Go 的 net/http）发起一个普通的 HTTP 请求。
Sidecar 拦截：请求被同 Pod 内的 istio-proxy（Envoy）容器拦截。
Envoy 查询服务发现：Envoy 检查自己的服务发现列表，问：“我知道 api.github.com这个服务吗？”
结果：未知服务：因为 api.github.com没有在 Kubernetes API Server 中注册，istiod从未将它下发给 Envoy。因此，Envoy 的服务发现列表里没有这个条目。
Envoy 的默认行为：PASSTHROUGH（穿透模式）：
由于找不到匹配的服务，Envoy 会认为这是一个它不需要管理的未知目标。
于是，它不会应用任何高级策略（如超时、重试、熔断）。
它直接将请求原样转发到 api.github.com通过 DNS 解析出来的 IP 地址。
后果：
无管理：这次调用就像没有 Istio 一样，不受任何 VirtualService 或 DestinationRule 规则的控制。
无观测性：Envoy 仍然会记录一些基础的 TCP 层指标（如连接数），但不会生成详细的 HTTP 指标（如 HTTP 状态码、延迟分布）、不会产生访问日志、也不会参与分布式追踪。这次调用在 Istio 的监控视角下几乎是“隐形”的。


当你创建了一个 ServiceEntry 后：
istiod会接收到这个新的服务定义。
istiod将这个外部服务的信息添加到其内部的服务注册中心。
istiod将更新后的服务列表下发给所有相关的 Sidecar 代理。
现在，当 Sidecar 代理再次收到访问 api.github.com的请求时，它能在自己的服务发现列表中找到这个条目，并将其识别为一个可管理的服务。
随后，它就可以为这个服务的流量应用你定义的任何 VirtualService（超时、重试）和 DestinationRule（负载均衡、熔断）策略，并收集完整的可观测性数据。
```

