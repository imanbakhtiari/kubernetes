## step by step for auto-completion
```
kubectl completion bash >/etc/bash_completion.d/kubectl
```
```
ehco ~/.bashrc >> source /etc/bash_completion
```
```
echo ~/.bashrc >> source <(kubectl completion bash)
```
```
echo 'alias k=kubectl' >>~/.bashrc
```

