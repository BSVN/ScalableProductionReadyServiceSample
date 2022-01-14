# ITNOA

#!/bin/bash

# Installing krew as pluging manager for kubectl from https://krew.sigs.k8s.io/docs/user-guide/setup/install/

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
    # Internet is mandatory
    if [[ ! is_internet_exist ]] ; then
        echo "Offline installing does not supported"
        exit 1
    fi

    if ! command -v git &> /dev/null ; then
        sudo apt install git
    fi

    if ! command -v curl &> /dev/null ; then
        sudo apt install curl
    fi

    if ! command -v tar &> /dev/null ; then
        sudo apt install tar
    fi

    # Show command content before the command is run (after variable resolution, there is a ++ symbol)
    # https://stackoverflow.com/a/58588917/1539100
    set -x
    cd "$(mktemp -d)"
    readonly OS="$(uname | tr '[:upper:]' '[:lower:]')"
    readonly ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    readonly KREW="krew-${OS}_${ARCH}"
    # -f : Fail silently on server errors
    # -s : Silent or quit mode
    curl -fSLO "http://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./"${KREW}" install krew

    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc

    cd -

    exec bash
else
    echo "krew has been install"
    exit 0
fi