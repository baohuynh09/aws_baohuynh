#!/bin/bash

# ------------------------------------------------------------------------#
# File Name : run.sh
# Creation Date : 28-08-2018
# Last Modified : Tue Aug 28 09:06:21 2018
# Created By : Bao Huynh (huynhthaibao07@gmail.com)

# Description :
# ------------------------------------------------------------------------#

#------------------------------------------ #
#
#------------------------------------------ #



#------------------------------------------ #
#              MAIN FUNCTION                #
#------------------------------------------ #
if [ "$1" == "-c" ]; then
	kubectl create -f mysql-efs.yaml
	sleep 2
	kubectl create -f wordpress-efs.yaml
	sleep 1
	kubectl create -f ingress_loadbalancer/ingress-controller.yml
	sleep 2
	kubectl create -f ingress_loadbalancer/ingress-controller-service.yml
	sleep 2
	kubectl create -f ingress_loadbalancer/ingress.yml

elif [ "$1" == "-d" ]; then
	kubectl delete -f ingress_loadbalancer/ingress.yml
	kubectl delete -f ingress_loadbalancer/ingress-controller-service.yml
	kubectl delete -f ingress_loadbalancer/ingress-controller.yml
	kubectl delete -f wordpress-efs.yaml
	kubectl delete -f mysql-efs.yaml
else
	echo "wrong: -c // -d"
fi
