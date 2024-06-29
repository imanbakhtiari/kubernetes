## If you use a private IP for apiserver-advertise-address, you won't be able to access the cluster from outside. To allow access from outside, follow these steps:

### To reset your Kubernetes cluster, follow these steps:

## Reset the cluster
```
kubeadm reset
```
## Run the following command to remove the CNI network:
```
rm -rf  /etc/cni/net.d
```
## Initialize the cluster and expose kubeapi:
```
kubeadm init --control-plane-endpoint 172.16.0.100 --apiserver-advertise-address=<PUBLIC_IP> --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log
```
## Remember to replace <PUBLIC_IP> with your actual public IP address.

## Install Calico by running:
```
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f "https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml"
```
## To join the worker, generate and print the join command:
```
kubeadm token create --print-join-command
```
### The join command will be printed and can be used to add worker nodes to your cluster.
### For install kubectl follow the link

### https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
