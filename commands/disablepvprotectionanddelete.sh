kubectl get pv --no-headers | awk '$2 == "1Gi" {print $1}' | xargs -I{} kubectl patch pv {} --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
kubectl get pv --no-headers | awk '$2 == "1Gi" {print $1}' | xargs -r kubectl delete pv --force --grace-period=0

