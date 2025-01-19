# Cloud Provider OpenStack Helm Chart Repository
- Add repo

```bash
helm repo add cpo https://kubernetes.github.io/cloud-provider-openstack
```

```bash
helm repo update
```

- Install Cinder CSI chart
```bash
helm install cinder-csi cpo/openstack-cinder-csi
```
- Install Manila CSI chart

```bash
helm install manila-csi cpo/openstack-manila-csi
```
