# vela-example

some workload and traits for vela, like hpa, istio virtualserver etc.

the charts is vela-core v1.0.5

## Install of kubevela

```bash
helm install -n vela-system kubevela charts/vela-core
```

## Components

micro-service: A service and deployment for long time running.
serverless: the comba of deployment, service and istio virtualservice.

