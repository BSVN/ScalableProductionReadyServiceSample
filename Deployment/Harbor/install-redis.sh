# ITNOA

#!/bin/bash

# Installing redis as cache server from (https://docs.redis.com/latest/kubernetes/deployment/quick-start/)

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# Redis is follow operator design pattern,
# For more information about operator please see https://developer.redis.com/create/kubernetes/kubernetes-operator/
#
# The operator definitions are packaged as a single generic YAML file. (called Bundle)
# TODO: Using Helm chart for installing redis operator
if [[ is_internet_exist ]] ; then
    if kubectl get deployment | grep redis-enterprise-operator &> /dev/null ; then
        echo "redis operator is existed so we do not need installing again"
        exit 0
    fi

    # Download the bundle for the latest release
    readonly bundle_version=`curl --silent https://api.github.com/repos/RedisLabs/redis-enterprise-k8s-docs/releases/latest | grep tag_name | awk -F'"' '{print $4}'`
    curl --silent -O https://raw.githubusercontent.com/RedisLabs/redis-enterprise-k8s-docs/$bundle_version/bundle.yaml

    kubectl apply -f bundle.yaml

    rm bundle.yaml

    if kubectl get deployment | grep redis-enterprise-operator &> /dev/null ; then
        echo "Installing completed..."
    fi
fi
