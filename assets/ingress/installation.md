## to install with helm
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

## to custom it
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
```
helm pull ingress-nginx/ingress-nginx
```
```
tar -xzvf ingress-nginx-4.10.1.tgz 
```
```
cd ingress-nginx
vi values.yaml values.yaml.bkp
```

```
helm upgrade --install ingress-nginx ./ingress-nginx -n ingress-nginx -f ./ingress-nginx/values.yaml
```
## EDIT values.yaml
### search for king == DaemonSet and type == ClusterIP and hostNetwork: true and hostPort: true
