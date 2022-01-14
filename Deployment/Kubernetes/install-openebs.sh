# ITNOA

#!/bin/bash

# Installing OpenEBS as a storage infrastructure on K8s from https://openebs.io/docs/user-guides/installation#installation-through-helm

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

readonly total_memory=$(free -m | awk '/^Mem:/{print $2}')

if [[ total_memory -lt 3900 ]] ; then
    echo "Insufficient memory for installing openebs mayastor engine, you have to provide 4GB memory at least"
    exit 1
fi

# Check kubectl cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if command -v kubectl &> /dev/null ; then
    echo "kubectl does not found, please install kubectl, and ensure K8s running on this node"
    exit 1
fi

# Check helm cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if command -v helm &> /dev/null && [[ is_internet_exist ]] ; then
    echo "Helm found, so we using helm..."

    # Check helm needed repo exist or not?
    if ! helm repo list | grep openebs &> /dev/null ; then
        # Before I can install the chart I will need to add the harbor repo to Helm
        helm repo add openebs http://openebs.github.io/charts
    fi

    # Follow https://medium.com/volterra-io/kubernetes-storage-performance-comparison-v2-2020-updated-1c0b69f0dcf4 instructions
    #‌ to prepare environment for installing OpenEBS

else
    echo "Helm must be install from 'install-helm.sh'"
fi