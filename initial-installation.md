[kuberentes installationn both client and master](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm)
## install kubernetes on ubuntu 22.04

```
vim /etc/fstab --> delete all swap line
```
### or
```
sudo sed -i '/\/swap.img/s/^/#/' /etc/fstab
```
### to verify
```
swapon -s --> for verify
```
### Disable firewall (ufw)
```
systemctl disable --now ufw
```
## Add kernel modules
```
vim /etc/modules-load.d/containerd.conf --> add
overlay
br_netfilter
```
## Kernel setting
```
vim /etc/sysctl.d/kubernetes.conf >> add

net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
```
## then

```
sysctl -p
```
### or

```
sudo vi /etc/sysctl.conf 

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```
## then

```
sysctl -p
```

## install required dependencies
```
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release conntrack apt-transport-https gpg
```

### install kubernetes baseon your version
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
### optional
```
sudo systemctl enable --now kubelet
```

