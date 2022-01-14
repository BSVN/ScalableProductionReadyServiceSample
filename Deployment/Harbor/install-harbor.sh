# ITNOA

#!/bin/bash

# Installing harbor as a private repository on K8s from https://goharbor.io/docs/2.4.0/install-config/harbor-ha-helm/

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi


# Check helm cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if command -v helm &> /dev/null && [[ is_internet_exist ]] ; then
    echo "Helm found, so we using helm..."

    # Check helm needed repo exist or not?
    if ! helm repo list | grep harbor &> /dev/null ; then
        # Before I can install the chart I will need to add the harbor repo to Helm
        helm repo add harbor https://helm.goharbor.io
    fi


else
    echo "Helm must be install from 'install-helm.sh'"
fi