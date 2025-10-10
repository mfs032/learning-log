# helm概念

```
在没使用helm之前，向kubernetes部署应用，我们要依次部署deployment、svc等、步骤较繁琐。况
且随着很多项目微服务化，复杂的应用在容器中部署以及管理显得较为复杂、helm通过打包的方式，支
持发布的版本管理和控制，很大程度上简化了Kubernetes应用的部署和管理

Helm本质就是让K8s的应用管理(Deployment,Service等）可配置，能动态生成。通过动态生成K8s
资源清单文件(deployment.yaml，service.yaml)。然后调用 Kubectl自动执行K8s资源部署
```



```
Helm是官方提供的类似于YUM的包管理器，是部署环境的流程封装。Helm有两个重要的概念：chart
和 release

Chart：是创建一个应用的信息集合，包括各种Kubernetes对象的配置模板、参数定义、依赖关
系、文档说明等。chart是应用部署的自包含逻辑单元。可以将chart想象成apt、yum中的软件
安装包

Release:是chart的运行实例，代表了一个正在运行的应用。当chart被安装到Kubernetes集
群，就生成一个release。chart能够多次安装到同一个集群，每次安装都是一个release

Helm cli:helm客户端组件,负责和 kubernetes apiS通信

Repository:用于发布和存储Chart 的仓库
```

## 安装

```bash
$ curl -fssL -o get_helm.sh
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
Schmod 700 get_helm.sh
$/get_helm.sh
```

## 查看仓库

```bash
helm repo ls
#v3办第一次安装默认无仓库
```

## 初始化

```bash
helm repo add 仓库名 仓库地址
helm repo add bitnami https://charts.bitnami.com/bitnami	#官方的地址
helm repo ls

#查看该仓库下有哪些chart包
helm search repo bitnami

#仓库的说明文件和索引文件
cd ~ ; ls -a ;	#有一个.cache文件
cd .cache ; ls #有一个helm文件
cd helm/ ; cd repository ; ls	#有一个repository文件，进去后一个是txt说明文件，一个是yaml索引文件
```

## 一些命令

```bash
helm repo update	#更新可以拿到的最新的charts列表
helm show values bitnami/apache	#查看bitanmi库下的apache的values yaml文件的默认配置(可修改的配置)

helm list -n default	#查看default命名空间下的所有release

helm show chart bitnami/apache	#查看chart包的元数据(例如名称、版本、依赖)，不可修改
helm show all bitnami/apache	#显示该chart包所有信息


#卸载
helm uninstall apache-xxxxx #该命令会卸载所有和该版本相关的所有资源和历史版本
helm uninstall apache-xxxxx --keep-history #该选项会保留历史版本
```

# chart

```bash
chart包类似rpm包

#在已填加的仓库中搜索带wordpress的chart包
helm search repo wordpress
```

## 例子--修改chart默认的values yaml配置文件

```bash
#创建一个yaml配置文件，并写一些内容
] cat <<EOF >values.yaml
>service:
>  type: NodePort
>EOF
] helm install -f values.yaml bitnami/apache --generate-name
#使用该values yaml配置文件创建release对象，这个values yaml的内容会自动替换默认的values yaml中对应的内容
```

## 安装chart包传递自定义参数的方式

### 1.使用默认的values.yaml(最低优先级)

```bash
Chart 开发者提供的默认配置。如果你不指定任何自定义参数，Helm 就会使用这个文件里的值
helm install my-release bitnami/apache
```



### 2.使用自定义的yaml文件(中优先级)

```
使用-f或者--values标志指定文件
helm install my-release biytnami/apache -f custom-values.yaml

也可以指定多个文件，后面的文件会覆盖前面文件相同的值
helm install my-release bitnami/apache -f values-1.yaml -f values-2.yaml
```



### 3.使用命令行参数(--set)(高优先级)，几乎不用

```
直接在命令行中设置参数，适用于快速测试或覆盖个别参数
helm install my-release bitnami/apache --set service.type=NodePort --set service.port=8080

```



# 升级和回滚chart包

```
helm upgrade -f clusterip.yaml apache-231421 bitnami/apache
上面apache-231421升级使用同一个chart包bitnami/apache，使用不同的values文件clusterip.yaml

helm history apache-231421
查看历史版本

helm rollback apache-231421 对应版本号(例如1	)
```

# 安装升级回滚的选项

```
--timeout：一个Goduration类型的值，用来表示等待Kubernetes命令完成的超时时间，默
认值为 5m0s。such as"300ms","-1.5h" or "2h45m".Valid time units are"ns","us" (or
"ps"),"ms","s", "m", "h".
--wait：表示必须要等到所有的Pods都处于ready状态，PVc都被绑定，Deployments都至
少拥有最小ready状态Pods个数(Desired减去maxUnavailable)，并且Services都具有IP
地址(如果是LoadBalancer，则为Ingress)，才会标记该release为成功。最长等待时间由
-timeout值指定。如果达到超时时间，release将被标记为FAlLED。注意：当Deployment的
replicas被设置为1，但其滚动升级策略中的maxUnavailable没有被设置为o时，-wait将返回
就绪，因为已经满足了最小readyPod数
-no-hooks：不运行当前命令的钩子，即为安装此chart时的已定义的安装前或者安装后的动
作
```



# 自定义chart包

```
helm creatw myapp
ls myapp/
在myapp目录下有如下文件
Chart.yaml:描述chart包的相关信息
chart/:该目录下存放chart包安装时要依赖的其它的chart包
templetes/:存放所有需要执行的资源清单文件
values.yaml:修改这个文件会替换templetes/目录下的资源清单文件中的参数
```

```yaml
其中一个templetes/目录下的资源清单文件，即模板文件之一
LRootek8s-MaSterO]mYAPPJ# cAT tEMPIATeS/seRVicE.YAMI
apiversion: v1
kind: service
metadata:
  labels:
  app: myapp-test
  name: myapp-test-{{ now | date "20060102030405" 3}-svc
spec:
  ports:
  - name: 80-80
    port: 80
    protocol: TCP
    targetPort: 80
    {{- if eq .values.service.type "NodePort"}}
    nodePort: {{.values.service.nodeport }}
    {{- end }}
  selector:
    app: myapp-test
  type: {{ .VAlUeS.seRvice.Type | qUote }}
```

```yaml
values.yaml示例
[root@k8s-mastero1 myapp]# cat values.yaml
# Default values for myapp.
#This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 5

image：
  repository: wangyanglinux/myapp
  tag: "v1.0"

service:
  type: NodePort
  nodeport: 32321
```

