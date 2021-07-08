# vela-example

[中文](./README.md) | [English](./README-en.md)

这是一个提供了 kubevela 实践的例子，基于 kubevela 创建了更贴合业务使用的抽象资源，比如针对开发关注的 micro-service，serverless，external-resource等组件，也包括各种运维关注的 监控exporter，网关ingressgateway，节点亲和nodeAffinity，华为云水平扩缩容HPA 等 traits。

本项目组件均在 vela-core v1.0.5 测试通过。

## kubevela安装

通过helm 安装
```bash
helm install kubevela --create-namespace --namespace vela-system kubevela/vela-core --version 1.0.6
```

通过本地文件安装
```bash
helm install -n vela-system kubevela charts/vela-core
```

## 组件(Components)

- micro-service: 主要是面向无状态的微服务这类应用创建，通过封装k8s的 deployment 和 service 资源实现.
- serverless: 主要是面向serverless这类对外直接提供服务这类应用创建，通过封装k8s的 deployment 和 service 和istio的 virtualservice 实现.
- distributed-app: 主要是面向需要维护状态的分布式应用创建，比如zookeeper,etcd，通过封装k8s的 statfulset 和 headless service 资源实现.
- external-resource: 主要面向需要引入外部资源的时候创建，通过封装k8s的 service 和 endpoint 实现。

## 组件特性(traits)

- exporter: 用于针对数据库的监控，主要用于external-resource这类组件，可以创建一个kafka,mysql,redis类似的exporter.
- ingressgateway: 用于对外做路由，只需提供 hosts 和 gateway 就可以将集群内服务提供给外部，又 istio 的 virtualservice 封装而成。
- nodeAffinity: 用于设置节点的亲和性，可以将指定的应用分配到对于的节点上，通过对 deployment 打 patch 实现。
- addvolume: 用于给应用添加外部挂载存储（只适配华为云），提供了ssd,nas,obs等存储资源对象，通过封装 PVC 对象实现。
- hpa: 用于做水平伸缩容的（只适配华为云）,提供基于cpu,memory伸缩容，同时可以控制扩缩容的时间，封装了 HPA 对象。
- healthChecker: 用于应用的健康检查，支持tcp, http, grpc和自定义放松。

## Cue debug

components
```bash
cue eval xxxx.cue -e output --out yaml
```

traits
```bash
cue eval xxxx.cue -e outputs --out yaml
```