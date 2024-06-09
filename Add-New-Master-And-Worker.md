## get token list on master node

```
kubeadm token list
```
## For master node run

## To create a new certificate key you must use 'kubeadm init phase upload-certs --upload-certs'.

```
kubeadm init phase upload-certs --upload-certs
```
```
kubeadm token create --certificate-key <YOUR OUTPUT> --print-join-command
```
## After that don't forget to add --apiserver-advertise-address at the end of your command.
For worker node

## Same as master node, but you don't need the --certificate-key and --control-plane
