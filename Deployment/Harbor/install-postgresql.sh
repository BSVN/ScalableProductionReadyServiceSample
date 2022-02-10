# ITNOA

#!/bin/bash

# Installing postgresql from (https://zercurity.medium.com/highly-available-and-scalable-postgresql-on-kubernetes-k8s-with-the-crunchy-postgresql-operator-cdf3a4da66ec)

is_internet_exist=0
# Check internet connection exist or not?
if ping 4.2.2.4 -c 2 -W 2 &> /dev/null ; then
    is_internet_exist=1
    echo "Internet is connected :)"
fi

# Postgresql is follow operator design pattern,
# For more information about operator please see https://developer.redis.com/create/kubernetes/kubernetes-operator/
if [[ is_internet_exist ]] ; then
    if command -v pgo &> /dev/null ; then
        echo "pgo is existed"
        # TODO: Check related helm charted installed
        exit 0
    fi

    # echo shell commands as they are executed
    set -x
    cd /tmp; git clone https://github.com/CrunchyData/postgres-operator.git pgo
    cd pgo

    # Installing pgo client from https://crunchydata.github.io/postgres-operator/latest/installation/pgo-client

    # -f : Fail silently on server errors
    # -s : Silent or quit mode
    [[ -f "pgo" ]] || curl -fSLO https://github.com/CrunchyData/postgres-operator/releases/latest/download/pgo
    sudo cp pgo /usr/local/bin/pgo
    sudo chmod +x /usr/local/bin/pgo

    # Configuring pgo client
    mkdir ${HOME?}/.pgo
    chmod 700 ${HOME?}/.pgo

    set +x

    if ! grep -q "pgo" ~/.bashrc ; then
        # TODO: Check port is available
        cat <<EOF | tee -a ~/.bashrc
 export PATH="$PATH:${HOME?}/.pgo/pgo/"
 export PGOUSER="${HOME?}/.pgo/pgo/pgouser"
 export PGO_CA_CERT="${HOME?}/.pgo/pgo/client.crt"
 export PGO_CLIENT_CERT="${HOME?}/.pgo/pgo/client.crt"
 export PGO_CLIENT_KEY="${HOME?}/.pgo/pgo/client.key"
 export PGO_APISERVER_URL='https://127.0.0.1:8443'
 export PGO_NAMESPACE=pgo
EOF
        source ~/.bashrc
    fi

    if command -v pgo &> /dev/null ; then
        echo "pgo installed successfully"
    else
        echo "pgo install failed"
        exit 1
    fi

    # Installing pgo operator
    if command -v helm &> /dev/null ; then
        echo "Helm found, so we using helm..."

        if [[ $(helm ls -n pgo-operator | wc -l) -gt 1 ]] ; then
            echo "OpenEBS is installed, so we do not need reinstall"
            exit 0
        fi

        cd postgres-operator/installers/helm
        helm install . \
            --name pgo-operator \
            --namespace pgo \
            --set postgresql.enabled=true \
            --set postgresql.persistence.enabled=true \
            --set postgresql.persistence.storageClass=openebs-hostpath \
            --set postgresql.persistence.size=3Gi \
            --set postgresql.persistence.accessMode=ReadWriteMany \
        /

        rm -r /tmp/pgo
    else
        echo "You must install helm first"
        exit 1
    fi
fi