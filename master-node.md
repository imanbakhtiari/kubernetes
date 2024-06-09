## Pull image

```
kubeadm config images pull
```
## Init cluster (Use this for cluster without HAProxy)
```
kubeadm init --control-plane-endpoint 172.16.0.100 --apiserver-advertise-address=172.16.0.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log
```
## Install Calico
```
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml"
```

## Join worker
```
kubeadm token create --print-join-command
```
