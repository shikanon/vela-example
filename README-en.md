# vela-example

some workload and traits for vela, like hpa, istio virtualserver etc.

the charts is vela-core v1.0.5

## Install of kubevela

install from helm command:
```bash
helm install kubevela --create-namespace --namespace vela-system kubevela/vela-core --version 1.0.6
```

install from local file:
```bash
helm install -n vela-system kubevela charts/vela-core
```

## Components

micro-service: A service and deployment for long time running, it is a set of no status services .
serverless: the comba of deployment, service and istio virtualservice.
distributed-app: distributed-app is a combo of StatefulSet + Service, it also provide storage cap.

## Cue debug

components
```bash
cue eval xxxx.cue -e output --out yaml
```

traits
```bash
cue eval xxxx.cue -e outputs --out yaml
```