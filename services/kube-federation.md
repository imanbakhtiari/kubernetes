# **Kubernetes Federation: Multi-Cluster Management Guide**

## **🚀 Overview**
Kubernetes Federation allows you to manage multiple Kubernetes clusters from a single control plane. This enables:
- **Multi-cluster workload deployment**
- **Failover & high availability**
- **Cross-cluster service discovery**
- **Centralized policy management**

This guide explains how to set up **KubeFed** for federating two Kubernetes clusters.

---

## **1️⃣ Prerequisites**
Ensure the following before proceeding:
- Two Kubernetes clusters:
  - **Cluster 1 (Main Control Plane)**
  - **Cluster 2 (Member Cluster)**
- Access to both clusters via `kubectl`.
- Helm installed (`helm version`).

Check available contexts:
```bash
kubectl config get-contexts
```

---

## **2️⃣ Install Kubernetes Federation (KubeFed)**

### **A. Install KubeFed on the Host Cluster**
```bash
kubectl config use-context <main-cluster>
helm repo add kubefed-charts https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/charts
helm repo update

helm install kubefed kubefed-charts/kubefed --namespace kube-federation-system --create-namespace
```

### **B. Verify Installation**
```bash
kubectl get pods -n kube-federation-system
```

### **C. Register the Member Cluster**
```bash
kubectl config use-context <main-cluster>
kubefedctl join <member-cluster> --host-cluster-context <main-cluster> --v=2
```

Verify registered clusters:
```bash
kubectl get federatedclusters
```

---

## **3️⃣ Deploying a Federated Application**

### **A. Enable Federation for Deployments**
```yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedDeployment
metadata:
  name: nginx
  namespace: default
spec:
  template:
    metadata:
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:latest
  placement:
    clusters:
    - name: <main-cluster>
    - name: <member-cluster>
```

Verify deployment:
```bash
kubectl get pods --all-namespaces --context=<main-cluster>
kubectl get pods --all-namespaces --context=<member-cluster>
```

---

## **4️⃣ Multi-Cluster Service Discovery**

### **A. Deploy a Federated Service**
```yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedService
metadata:
  name: nginx
  namespace: default
spec:
  template:
    spec:
      selector:
        app: nginx
      ports:
      - protocol: TCP
        port: 80
        targetPort: 80
  placement:
    clusters:
    - name: <main-cluster>
    - name: <member-cluster>
```

Verify services:
```bash
kubectl get services --context=<main-cluster>
kubectl get services --context=<member-cluster>
```

---

## **5️⃣ Disaster Recovery & Load Balancing**

### **A. Automatic Failover**
Simulate failure by draining a node:
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
```

Check if pods migrate:
```bash
kubectl get pods --context=<main-cluster>
kubectl get pods --context=<member-cluster>
```

### **B. Global Load Balancing**
Use Ingress Federation for global traffic routing:
```yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedIngress
metadata:
  name: nginx-ingress
  namespace: default
spec:
  template:
    spec:
      rules:
      - host: nginx.example.com
        http:
          paths:
          - backend:
              service:
                name: nginx
                port:
                  number: 80
  placement:
    clusters:
    - name: <main-cluster>
    - name: <member-cluster>
```

---

## **6️⃣ Best Practices for Kubernetes Federation**
✔ **Use KubeFed API for Multi-Cluster Management**  
✔ **Enable Role-Based Access Control (RBAC)**  
✔ **Monitor Cluster Health with Prometheus/Grafana**  
✔ **Use GitOps (ArgoCD/FluxCD) for Multi-Cluster Deployments**  
✔ **Ensure Network Connectivity Across Clusters (Calico, Cilium, Istio)**  

---

## **🎯 Conclusion**
Now you have **two federated Kubernetes clusters** with:
✅ **Centralized Deployment & Service Discovery**  
✅ **Automatic Failover & Multi-Cluster Load Balancing**  
✅ **Scalability & High Availability Across Regions**  



