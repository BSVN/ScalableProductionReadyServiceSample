# ITNOA

#!/bin/bash

# https://docs.openebs.io/v280/docs/next/ugmayastor.html
# https://www.golinuxcloud.com/configure-hugepages-vm-nr-hugepages-red-hat-7/

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# TODO: Please use hugeadm for more imprative configuration
if ! command -v hugeadm &> /dev/null && [[ is_internet_exist ]] ; then
    sudo apt install libhugetlbfs-bin
fi

readonly hugepages_size=$(sysctl -a 2> /dev/null | grep vm.nr_hugepages | cut -d ' ' -f 3 | head -n 1)

if [[ -z hugepages_size || hugepages_size -lt 512 ]] ; then
    echo "hugepages does not sufficient, so we increasing it..."

    # Persist number of hugepages

    # for more modularity instead of echo vm.nr_hugepages = 1024 | sudo tee -a /etc/sysctl.conf
    # creating new file in sysctl.d and change desired value into it
    echo vm.nr_hugepages = 1024 | sudo tee /etc/sysctl.d/90-hugepages.conf

    sudo sysctl -p

    readonly new_hugepages_size=$(sysctl -a 2> /dev/null | grep vm.nr_hugepages | cut -d ' ' -f 3 | head -n 1)

    if ! [[ -z new_hugepages_size || new_hugepages_size -lt 512 ]] ; then
        echo "Change is successfully"
    fi
fi
