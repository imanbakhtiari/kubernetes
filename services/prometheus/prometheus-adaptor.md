```
helm install prometheus-adapter-a prometheus-community/prometheus-adapter \
  --set prometheus.url="http://prometheus-a.default.svc:9090"
```
