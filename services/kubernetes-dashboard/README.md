```
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

```
kubectl -n kubernetes-dashboard get pods
```


## now get the token bearer to access UI dashboard

```
cat <<EOF>> dashboard-serviceaccount.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

```
kubectl create -f dashboard-serviceaccount.yml
```

```
kubectl --kubeconfig config.yml -n kubernetes-dashboard create token admin-user
```

```
kubectl -n kubernetes-dashboard port-forward --address 0.0.0.0 svc/kubernetes-dashboard-kong-proxy 8443:443 &
```
