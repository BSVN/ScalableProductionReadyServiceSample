# ITNOA

#!/bin/bash

# Installing kustomize from https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi


if [[ is_internet_exist ]] ; then
    if command -v kustomize &> /dev/null ; then
        echo "kustomize is existed"
        exit 0
    fi
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
    [[ -x "kustomize" ]] && sudo mv kustomize /usr/local/bin/
else
    echo "Please connect to internet to install kustomize"
    exit 1
fi