# ITNOA

#!/bin/bash

# Check dotnet cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if ! command -v dotnet &> /dev/null ; then
    # https://askubuntu.com/a/1214268/101335
    # TODO: Move to specific function (os name)
    readonly os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')
    if [ "$os_name" == "Ubuntu" ]
    then
        echo "system is Ubuntu"

        # Add the Microsoft package signing key to my list of trusted keys and add the package respository
        wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb

        # Install the SDK
        sudo apt-get update; \
        sudo apt-get install -y apt-transport-https && \
        sudo apt-get update && \
        sudo apt-get install -y dotnet-sdk-6.0
    elif [ "$os_name" == "CentOS" ]
    then
        echo "system is CentOS"
    else
        echo "system is $os_name"
    fi
fi