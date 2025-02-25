# **Cilium Gateway Configuration Guide**

## **🚀 Overview**
Cilium is an advanced **eBPF-based networking solution** for Kubernetes that provides security, observability, and high-performance networking. It includes features such as:
- **L4/L7 network policies**
- **BGP & eBPF-powered routing**
- **Service Mesh replacement (Cilium Service Mesh)**
- **Gateway API support for ingress and egress traffic**

This guide covers **configuring Cilium Gateway API** for Kubernetes ingress and egress traffic management.

---

## **1️⃣ Prerequisites**
Before setting up Cilium Gateway, ensure:
- A **Kubernetes cluster (v1.21+)**
- `kubectl` and `helm` installed
- Cilium installed with Gateway API support

Check cluster health:
```bash
kubectl get nodes
```

Ensure Cilium is installed:
```bash
cilium status
```

---

## **2️⃣ Install Cilium with Gateway API Support**

### **A. Install Cilium with Helm**
```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium --namespace kube-system \
    --set gatewayAPI.enabled=true
```

### **B. Verify Installation**
```bash
kubectl get pods -n kube-system | grep cilium
kubectl get gatewayclass
```

---

## **3️⃣ Configure Cilium as an Ingress Gateway**

### **A. Create a GatewayClass**
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: cilium-gateway
spec:
  controllerName: io.cilium/gateway-controller
```
Apply:
```bash
kubectl apply -f gatewayclass.yaml
```

### **B. Create a Gateway Resource**
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: cilium-ingress-gateway
  namespace: default
spec:
  gatewayClassName: cilium-gateway
  listeners:
  - protocol: HTTP
    port: 80
    name: http
    allowedRoutes:
      namespaces:
        from: All
```
Apply:
```bash
kubectl apply -f gateway.yaml
```

### **C. Create an HTTPRoute for Traffic Management**
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: my-route
  namespace: default
spec:
  parentRefs:
  - name: cilium-ingress-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: my-app-service
      port: 8080
```
Apply:
```bash
kubectl apply -f httproute.yaml
```

---

## **4️⃣ Configure Cilium as an Egress Gateway**

### **A. Enable Cilium Egress Gateway**
```bash
helm upgrade cilium cilium/cilium --namespace kube-system \
    --set egressGateway.enabled=true
```

### **B. Define an Egress Gateway Policy**
```yaml
apiVersion: cilium.io/v2
kind: CiliumEgressGatewayPolicy
metadata:
  name: allow-external-access
spec:
  destinationCIDRs:
  - 0.0.0.0/0
  egressGateway:
    name: cilium-egress-gateway
    namespace: kube-system
  selector:
    matchLabels:
      app: backend
```
Apply:
```bash
kubectl apply -f egress-gateway-policy.yaml
```

### **C. Verify Egress Gateway Configuration**
```bash
kubectl get ciliumegressgatewaypolicies
```

---

## **5️⃣ Monitoring & Debugging**

### **A. Check Gateway Status**
```bash
kubectl get gateway -A
kubectl get httproute -A
```

### **B. Debug Traffic Flows with Hubble**
```bash
cilium hubble enable
hubble observe --since 10m
```

---

## **6️⃣ Best Practices for Cilium Gateway**
✔ **Use fine-grained HTTPRoutes for security**  
✔ **Monitor traffic with Hubble for debugging**  
✔ **Enable mTLS for secure communication**  
✔ **Use network policies to restrict access**  

---

## **🎯 Conclusion**
Now you have configured **Cilium Gateway** with:
✅ **Ingress Gateway for HTTP traffic**  
✅ **Egress Gateway for external access**  
✅ **Network policies and traffic monitoring**  



