# 📦 External NFS Server + Kubernetes Integration via CSI Driver

This guide walks you through setting up an **NFS server on an external Linux machine** and integrating it with **Kubernetes** using the **NFS CSI driver (v4.5.0)**.

---

## 🧩 Architecture

```
+----------------------+         +----------------------------+
| External NFS Server  | <-----> | Kubernetes Worker/Control |
| 192.168.1.100        |         | Uses PVCs from NFS         |
+----------------------+         +----------------------------+
```

---

## 🔧 Step 1: Set Up NFS Server

### 📋 Install NFS server

On the external Linux VM (e.g., Ubuntu):

```bash
sudo apt update
sudo apt install nfs-kernel-server -y
```

### 📁 Create shared directory

```bash
sudo mkdir -p /srv/nfs/k8s
sudo chown nobody:nogroup /srv/nfs/k8s
```

### 📝 Configure exports

Edit the file `/etc/exports`:

```bash
sudo nano /etc/exports
```

Add this line:

```
/srv/nfs/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

Apply the export:

```bash
sudo exportfs -rav
```

### 🔥 Allow NFS ports through firewall (optional)

```bash
sudo ufw allow from 192.168.1.0/24 to any port nfs
sudo ufw allow from 192.168.1.0/24 to any port 2049 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 111 proto tcp
```

---

## 🚀 Step 2: Install NFS CSI Driver in Kubernetes

Install with:

```bash
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.5.0/deploy/install-driver.sh | bash -s v4.5.0 --
```

Verify:

```bash
kubectl get pods -n kube-system -l app=nfs-csi-node
kubectl get pods -n kube-system -l app=nfs-csi-controller
```

---

## 📦 Step 3: Create a StorageClass

Save this as `nfs-storageclass.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: 192.168.1.100
  share: /srv/nfs/k8s
reclaimPolicy: Retain
volumeBindingMode: Immediate
allowVolumeExpansion: true
```

Apply it:

```bash
kubectl apply -f nfs-storageclass.yaml
```

---

## 📄 Step 4: Create a PVC

Save this as `nfs-test-pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: nfs-csi
```

Apply:

```bash
kubectl apply -f nfs-test-pvc.yaml
kubectl get pvc test-nfs-pvc
```

---

## 🧪 Step 5: Create a Pod using the PVC

Save this as `nfs-test-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-nfs-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - mountPath: /data
          name: nfs-vol
  volumes:
    - name: nfs-vol
      persistentVolumeClaim:
        claimName: test-nfs-pvc
```

Apply:

```bash
kubectl apply -f nfs-test-pod.yaml
```

Test inside the pod:

```bash
kubectl exec -it test-nfs-pod -- sh
echo "hello from NFS" > /data/hello.txt
cat /data/hello.txt
```

---

## ✅ Done!

You now have:
- NFS server outside the cluster
- Kubernetes using dynamic NFS volumes
- Working PVC + Pod mount

---

## 📚 References

- https://github.com/kubernetes-csi/csi-driver-nfs
- https://kubernetes.io/docs/concepts/storage/

