# sklearn server 使用

## 安装 sklearn server

### 本地镜像编译运行

```bash
# 编译
docker build -t swr.cn-north-4.myhuaweicloud.com/hw-zt-k8s-images/sklearnserver -f sklearn.Dockerfile .
# 运行
docker run -it --rm -p 8080:8080 swr.cn-north-4.myhuaweicloud.com/hw-zt-k8s-images/sklearnserver
```

### k8s运行

上传镜像：
```bash
docker build -t swr.cn-north-4.myhuaweicloud.com/hw-zt-k8s-images/sklearnserver:demo-iris -f sklearn.Dockerfile .
docker push swr.cn-north-4.myhuaweicloud.com/hw-zt-k8s-images/sklearnserver:demo-iris
```

使用 `vela up` 部署:

```bash
$ vela up -f demo-iris-01.yaml
Parsing vela appfile ...
Load Template ...

Rendering configs for service (demo-iris)...
Writing deploy config to (.vela/deploy.yaml)

Applying application ...
Checking if app has been deployed...
App has not been deployed, creating a new deployment...
✅ App has been deployed 🚀🚀🚀
    Port forward: vela port-forward demo-iris-01
             SSH: vela exec demo-iris-01
         Logging: vela logs demo-iris-01
      App status: vela status demo-iris-01
  Service status: vela status demo-iris-01 --svc demo-iris
```

部署好后可以测试：
```bash
$ curl -i -d '{"instances":[[5.1, 3.5, 1.4, 0.2]]}' -H "Content-Type: application/json" -X POST demo-iris.rcmd.testing.mpengine:8000/v1/models/model:predict
{"predictions": [0]}
```

## 接口说明

### 服务存活检测

```bash
curl 127.0.0.1:8080/
# 或者
curl 127.0.0.1:8080/v2/health/live
```

### 模型预测

demo 示例模型使用的是 `iris` 数据训练，我们可以通过以下方法获取：
```python
from sklearn import datasets

iris = datasets.load_iris()
X, y = iris.data, iris.target
print(X[0],y[0])
# [5.1 3.5 1.4 0.2] 0
```

预测提交数据使用的 `POST` 方法，数据格式为`{"instances": <数组>}`：

```bash
$ curl -d '{"instances":[[5.1, 3.5, 1.4, 0.2]]}' -X POST 127.0.0.1:8080/v1/models/model:predict
{"predictions": [0]}

$ curl -d '{"instances":[[5.9, 3.0 , 5.1, 1.8]]}' -X POST 127.0.0.1:8080/v1/models/model:predict
{"predictions": [2]}
```


### 其他接口实现

kfserving 提供了多种方法的接口供实现，详细见`kfserving/kfserving/kfserver.py`:
```python
...
def create_application(self):
    return tornado.web.Application([
        # Server Liveness API returns 200 if server is alive.
        (r"/", LivenessHandler),
        (r"/v2/health/live", LivenessHandler),
        (r"/v1/models",
            ListHandler, dict(models=self.registered_models)),
        (r"/v2/models",
            ListHandler, dict(models=self.registered_models)),
        # Model Health API returns 200 if model is ready to serve.
        (r"/v1/models/([a-zA-Z0-9_-]+)",
            HealthHandler, dict(models=self.registered_models)),
        (r"/v2/models/([a-zA-Z0-9_-]+)/status",
            HealthHandler, dict(models=self.registered_models)),
        (r"/v1/models/([a-zA-Z0-9_-]+):predict",
            PredictHandler, dict(models=self.registered_models)),
        (r"/v2/models/([a-zA-Z0-9_-]+)/infer",
            PredictHandler, dict(models=self.registered_models)),
        (r"/v1/models/([a-zA-Z0-9_-]+):explain",
            ExplainHandler, dict(models=self.registered_models)),
        (r"/v2/models/([a-zA-Z0-9_-]+)/explain",
            ExplainHandler, dict(models=self.registered_models)),
        (r"/v2/repository/models/([a-zA-Z0-9_-]+)/load",
            LoadHandler, dict(models=self.registered_models)),
        (r"/v2/repository/models/([a-zA-Z0-9_-]+)/unload",
            UnloadHandler, dict(models=self.registered_models)),
    ])
...
```