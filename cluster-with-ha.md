
## Virtual IP managed by Keepalived on the load balancer nodes

| control-planes | workers       | virtual-ip     |
|:---------------|:-------------:|---------------:|
| 10.130.4.140   |  10.130.4.143 |  10.130.4.150  |
| 10.130.4.141   |  10.130.4.144 |                |
| 10.130.4.142   |  10.130.4.145 |                |

```bash
cat <<EOF > /etc/keepalived/check_apiserver.sh
#!/bin/sh

errorExit() {
  echo "*** \$@" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://10.130.4.150:6443/ -o /dev/null || errorExit "Error GET https://10.130.4.150:6443/"
if ip addr | grep -q 10.130.4.150; then
  curl --silent --max-time 2 --insecure https://10.130.4.150:6443/ -o /dev/null || errorExit "Error GET https://10.130.4.150:6443/"
fi
EOF
```
## keepalived configuraion
```bash
cat <<EOF > /etc/keepalived/keepalived.conf
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3 # check api server every 3 seconds
  timeout 10 # timeout second if api server doesn't answered
  fall 5 # failed time
  rise 2 # success 2 times
  weight -2 # if failed is done it reduce 2 of the weight
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth1 # set your interface
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass mysecret
    }
    virtual_ipaddress {
        172.16.100.100
    }
    track_script {
        check_apiserver
    }
}
EOF
```
## Enable & start keepalived service
```bash
systemctl enable --now keepalived && && systemctl restart keepalived
```


```bash
cat <<EOF >> /etc/haproxy/haproxy.cfg

frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server k8s-test-master1 10.130.4.140:6443 check fall 3 rise 2
    server k8s-test-master2 10.130.4.141:6443 check fall 3 rise 2
    server k8s-test-master3 10.130.4.142:6443 check fall 3 rise 2
```


## Enable & restart haproxy service
```bash
systemctl enable haproxy && systemctl restart haproxy
```

## Add virtual ip to all of the /etc/hosts nodes like this

```bash
10.130.4.140 k8s1
10.130.4.141 k8s2
10.130.4.142 k8s3
10.130.4.143 worker1
10.130.4.144 worker2
10.130.4.145 worker5
```
## Verify
### Run watch kubectl get node on one node and down one ha proxy or master nodes.
