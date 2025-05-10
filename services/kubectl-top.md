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

- top 10 most ram usage in cluster
```bash
kubectl top pod --all-namespaces --no-headers | sort -k4 -nr | awk '{printf "%-15s %-50s %-10s %.2f GB\n", $1, $2, $3, $4 / 1024}' | head -10
```

- top 10 cpu usage pod in cluster
```bash
kubectl top pod --all-namespaces --no-headers | sort -k3 -nr | head -10
```
