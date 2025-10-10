# 负载均衡 

```
四层负载
	特性：一次完整的TCP连接，由C和RS建立，D只起到转发的作用

七层负载
	特性：两次完整的TCP连接，由C和D建立，D和RS建立
```



# Ingress Controller的七层负载

![Ingress的七层负载](10-k8s%20Ingress.assets/Ingress%E7%9A%84%E4%B8%83%E5%B1%82%E8%B4%9F%E8%BD%BD.png)

![Ingress架构](10-k8s%20Ingress.assets/Ingress%E6%9E%B6%E6%9E%84.png)

## Ingress Controller暴露给集群外部

```bash
Ingress Controller 本身是一个部署在集群内的应用程序（一堆 Pod）。为了让外部流量能够找到它，我们需要用一个 Service 来暴露它

Service 类型：通常使用 LoadBalancer类型。这会命令云提供商（如 AWS, GCP, Azure）自动创建一个外部负载均衡器，并为其分配一个唯一的、稳定的公网 IP 地址。

结果：所有发往您网站或应用的流量（例如，用户访问 www.myapp.com），都会通过 DNS 解析，最终指向这个外部负载均衡器的 IP。这个负载均衡器会将流量转发到后端的 Ingress Controller Pods。
```

## Ingress Controller的转发规则

```
规则来源：Ingress Controller 会持续监控 Kubernetes API，监听 Ingress 对象的创建和更改。
执行规则：当它发现您创建的 Ingress 资源（YAML 文件）时，会读取其中定义的规则
动态配置：Ingress Controller 会将这些规则实时转化为它内部使用的负载均衡器（如 Nginx、Traefik）的配置，并使其生效。
```

## Ingress Controller如何转发

```
流量路径是：
Ingress Controller -> Pod IP
而不是：
Ingress Controller -> Service ClusterIP -> (再由 kube-proxy 通过 iptables/ipvs 转发到) -> Pod IP

原因
减少网络跳数，提升性能：
如果经过 Service ClusterIP，需要多经过一次 kube-proxy设置的 iptables/ipvs 规则进行转发。直接连接到 Pod 减少了中间环节，降低了延迟。
保持客户端真实 IP：
这是至关重要的一点。如果流量先到达 Service，那么进行 SNAT（源地址转换）后，后端 Pod 看到的流量来源将是集群内部某个节点的 IP 或 Service 的 IP，而不是用户的真实 IP。
Ingress Controller 作为七层代理，在直接连接到 Pod 时，可以通过在 HTTP 头信息（如 X-Forwarded-For, X-Real-IP）中设置客户端真实 IP，并直接传递给后端 Pod。这样应用程序就能知道谁真正发起了请求。
更灵活的健康检查：
Ingress Controller 可以自行对后端 Pod 执行更精细的七层健康检查（例如检查 HTTP 状态码），而不仅仅是 Service 提供的四层（TCP 连接）健康检查。如果 Pod 健康检查失败，Ingress Controller 会立即将其从负载均衡池中剔除，而无需等待 kubelet 更新 Service 的 Endpoint。

通过监听 Endpoints 或 EndpointSlices API 来实现。
Ingress Controller 不会去读 Service 的 ClusterIP，而是会去监听这些 Endpoints 对象的变化。这样，它就能直接获取到所有健康 Pod 的真实 IP 地址列表。
```

## Ingress Controller也可以做四层代理

```bash
```

