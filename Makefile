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
	
push-rogue-jndi:
	docker push quay.io/${QUAY_USER}/rogue-jndi
