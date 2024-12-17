## installation

```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.2/deploy/longhorn.yaml
```

```
kubectl get pods \
--namespace longhorn-system \
--watch
```

```
kubectl -n longhorn-system get pod
```

```
kubectl -n longhorn-system port-forward --address 0.0.0.0 svc/longhorn-frontend 8080:80 & 
```
