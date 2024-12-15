kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace, POD:.metadata.name, SCRAPE:.metadata.annotations.prometheus\.io/scrape, PORT:.metadata.annotations.prometheus\.io/port"

