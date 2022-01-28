# ITNOA

#!/bin/bash

# Creating redis cluster from (https://docs.redis.com/latest/kubernetes/deployment/quick-start/)

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# We are using redis operator to creating redis cluster
if kubectl get deployment | grep redis-enterprise-operator &> /dev/null ; then
    kubectl apply -f harbor-redis-cluster.yaml

    if kubectl get redisenterpriseclusters.app.redislabs.com | grep harbor-cluster &> /dev/null ; then
        echo "cluster created successfully"
    fi
else
    echo "redis operator is not install, please install it before creating redis cluster from install-redis.sh"
    exit 1
fi

# TODO: Install redis insight for web administartion https://docs.redis.com/latest/ri/

# For creating redis db for harbor type: kubectl apply -f harbor-redis-db.yaml
# Connectivity Information: kubectl get secret/redb-harbordb -o yaml