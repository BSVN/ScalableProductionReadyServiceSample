#!/bin/bash

# ITNOA
#
# Resaa Co. Copy Right 1401|2022. All rights reserved
#
# This script is used to prepare the ansible installation.

# Check helm cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if ! command -v ansible &> /dev/null ; then
    # https://askubuntu.com/a/1214268/101335
    # TODO: Move to specific function (os name)
    readonly os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')
    if [ "$os_name" == "Ubuntu" ]
    then
        echo "system is Ubuntu"
        sudo apt install -y ansible
        sudo apt install -y sshpass
        ansible-galaxy collection install collections/community-general-7.3.0.tar.gz
    elif [ "$os_name" == "CentOS" ]
    then
        echo "system is CentOS"
    elif [ "$os_name" == "Red" ]
    then
        echo "system is RHEL Linux"
        sudo yum install --disableplugin=subscription-manager -y ansible

        # https://www.redhat.com/sysadmin/ansible-system-role 
        sudo yum install --disableplugin=subscription-manager -y rhel-system-roles

        ansible-galaxy collection install community-docker-2.3.0.tar.gz

        # https://stackoverflow.com/a/66271045/1539100
        sudo yum install --disableplugin=subscription-manager -y python3

        ansible-galaxy collection install community-zabbix-1.5.1.tar.gz
    else
        echo "system is $os_name"
    fi
else
    echo "ansible installed on system"
fi