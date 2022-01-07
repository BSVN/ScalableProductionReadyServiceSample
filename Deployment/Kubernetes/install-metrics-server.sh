#ITNOA

#!/bin/bash

# Installing metrics server, that describe in https://github.com/kubernetes-sigs/metrics-server

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# Check helm exist or not?
# https://stackoverflow.com/a/677212/1539100
if command -v helm &> /dev/null && [[ is_internet_exist ]] ; then
    echo "Helm found, so we using helm..."

    # Check helm needed repo exist or not?
    if ! helm repo list | grep metrics-server &> /dev/null ; then
        # Before I can install the chart I will need to add the metrics-server repo to Helm
        helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    fi

    # Install the chart
    helm upgrade --install --namespace kube-system --reuse-values -f metrics-server-override-values.yaml metrics-server metrics-server/metrics-server
elif [[ is_internet_exist ]] ; then
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
else
    if [[ ! -s metrics-server-components.yaml ]] ; then
        # TODO: Send message to log
        echo "metrics-server-components.yaml does not exists!"
        exit 1
    fi
    kubectl apply -f metrics-server-components.yaml
fi