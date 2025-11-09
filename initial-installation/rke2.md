- first master node
```
mkdir /etc/rancher/
mkdir /etc/rancher/rke2/
```

```
sudo vi /etc/rancher/rke2/config.yaml
```

- in first master
```
cluster-init: true
token:  DSes9Y4UAYUlHRsQ92HnFf1DUA1jRDYWIi3mEfDNto14GIvtJP1
#server: https://rke2-1:9345
tls-san:
  - 172.26.2.161
  - 172.26.2.162
  - 172.26.2.163
  - rke2-1
  - rke2-2
  - rke2-3
disable:
  - rke2-ingress-nginx
  - rke2-metrics-server
  - rke2-snapshot-controller
  - rke2-snapshot-controller-crd
  - rke2-snapshot-validation-webhook
cni: none
disable-kube-proxy: "true"
disable-cloud-controller: "true"
enable-servicelb: "false"
```

- in other masters
```
mkdir /etc/rancher/
mkdir /etc/rancher/rke2/
```

```
sudo vi /etc/rancher/rke2/config.yaml
```

```
token:  DSes9N4UAYUlHRsQ92HnFf1DUA1jRDYWIi3mEfDNto14GIvtJP1
server: https://rke2-1:9345
tls-san:
  - 172.26.2.161
  - 172.26.2.162
  - 172.26.2.163
  - rke2-1
  - rke2-2
  - rke2-3
disable:
  - rke2-ingress-nginx
  - rke2-metrics-server
  - rke2-snapshot-controller
  - rke2-snapshot-controller-crd
  - rke2-snapshot-validation-webhook
cni: none
disable-kube-proxy: "true"
disable-cloud-controller: "true"
enable-servicelb: "false"
```

- and then in all master nodes

```
curl -sfL https://get.rke2.io | sh -
```

```
systemctl enable rke2-server.service
systemctl start rke2-server.service
```

### Cilium Installation with EBPF
```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

```
cilium install \
  --version 1.18.3 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=172.26.2.170 \
  --set k8sServicePort=6444 \
  --set ipam.mode=kubernetes \
  --set routingMode=native \
  --set autoDirectNodeRoutes=true \
  --set ipv4NativeRoutingCIDR=10.42.0.0/16 \
  --set enableIPv4=true \
  --set enableIPv4Masquerade=true \
  --set ipMasqAgent.enabled=false \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set bpf.masquerade=true \
  --set bpf.hostLegacyRouting=false \
  --set hostFirewall.enabled=false
```

```
cilium status
```

