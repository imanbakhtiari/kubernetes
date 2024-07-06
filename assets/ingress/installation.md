## to install
```
kubectl create namespace ingress-nginx
```

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

```
helm install ingress-nginx ingress-nginx/ingress-nginx  \
--namespace ingress \
--set controller.ingressClassResource.name=nginx
```

## to uninstall
```bash
helm uninstall ingress-nginx -n ingress-nginx
```
