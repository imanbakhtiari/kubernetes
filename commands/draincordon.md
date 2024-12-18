- drain is used to safely evict all pods from a node, typically for maintenance or shutdown purposes. It gracefully terminates all pods running on the node while respecting PodDisruptionBudgets (PDBs). It is useful for preparing a node for shutdown, reboot, or maintenance.

```
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
```
```
kubectl drain <node-name> --ignore-daemonsets
```


- cordon is used to prevent new pods from being scheduled on a node. When a node is cordoned, it becomes unschedulable, meaning no new pods will be scheduled on it, but the pods that are already running on the node will continue to function.


```
kubectl cordon <node-name>
```
```
kubectl uncordon <node-name>
```


