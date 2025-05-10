### installation 
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

```bash
kubectl top pod -n namespace
```

- see ram base on GB
```bash
kubectl top pod -n namespace --no-headers | awk '{printf "%-60s %-10s %.2f GB\n", $1, $2, $3 / 1024}'
```
