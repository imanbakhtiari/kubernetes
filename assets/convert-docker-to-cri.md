## For docker images

```
sudo docker save -o imagename.tar imagename
```

## OR For containerd images

```
ctr image export <output-filename> <image-name>
```

## export to the ctr with k8s.io namespace

```
ctr -n=k8s.io images import imagename.tar
```

## to check
```
sudo crictl images
```
