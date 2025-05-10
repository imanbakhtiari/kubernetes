#!/bin/bash

# Set namespace to your specific namespace if it's different from 'monitoring'
NAMESPACE="monitoring"
PODNAME="webserver"
# Get all pods with names matching the 'webserver*' pattern in the specified namespace
PODS=$(kubectl get pods -n $NAMESPACE -o name | grep 'webserver')

# Iterate over each pod and execute the rm command
for POD in $PODS; do
  echo "Executing command on $POD..."
  kubectl exec -n $NAMESPACE $POD -c netdata -- rm -rf /var/lib/netdata/lock/web_log_nginx.collector.lock
done

echo "Command executed on all matching pods."


