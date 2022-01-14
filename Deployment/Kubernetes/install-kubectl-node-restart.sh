# ITNOA

#!/bin/bash

# Installing kubectl-node-restart as kubectl plugin from https://github.com/MnrGreg/kubectl-node-restart

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# Check kubectl cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if ! command -v kubectl &> /dev/null ; then
    echo "kubectl does not found, please install kubectl, and ensure K8s running on this node"
    exit 1
fi

# TODO:‌ Replace all this work with docker image

# Check krew install or not?
if ! kubectl krew &> /dev/null ; then
    echo "plese install krew from install-krew.sh"
    exit 1
fi

if ! kubectl node-restart --help &> /dev/null ; then
    # Internet is mandatory
    if [[ ! is_internet_exist ]] ; then
        echo "Offline installing does not supported"
        exit 1
    fi

    kubectl krew updated
    kubectl krew install node-restart
fi
