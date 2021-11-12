# ITNOA

#!/bin/bash

# Check helm cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if ! command -v helm &> /dev/null ; then
    # https://askubuntu.com/a/1214268/101335
    # TODO: Move to specific function (os name)
    readonly os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')
    if [ "$os_name" == "Ubuntu" ]
    then
        echo "system is Ubuntu"

        curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
        sudo apt-get install apt-transport-https --yes
        echo "deb http://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
        sudo apt-get update
        sudo apt-get install helm

    elif [ "$os_name" == "CentOS" ]
    then
        echo "system is CentOS"
    else
        echo "system is $os_name"
    fi
fi