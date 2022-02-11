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

    # echo shell commands as they are executed
    set -x
    cd /tmp; git clone https://github.com/CrunchyData/postgres-operator-examples.git pgo
    cd pgo
    set +x

    # Installing pgo operator
    # https://access.crunchydata.com/documentation/postgres-operator/v5/installation/helm/
    if command -v helm &> /dev/null ; then
        echo "Helm found, so we using helm..."

        if [[ $(helm ls -n pgo | wc -l) -gt 1 ]] ; then
            echo "Postgresql Operator is installed, so we do not need reinstall"
            exit 0
        fi

        helm install pgo-operator -n pgo helm/install \
            --create-namespace \
            --set postgresql.enabled=true \
            --set postgresql.persistence.enabled=true \
            --set postgresql.persistence.storageClass=openebs-hostpath \
            --set postgresql.persistence.size=3Gi \
            --set postgresql.persistence.accessMode=ReadWriteMany

    else
        echo "You must install helm first"
        exit 1
    fi

    if command -v pgo &> /dev/null ; then
        echo "pgo is existed"
        # TODO: Check related helm charted installed
        exit 0
    fi

    # Installing pgo client from https://crunchydata.github.io/postgres-operator/latest/installation/pgo-client
    # TODO: I think version 5 of PGO is not compatible with version 4 of PGO, so client-setup.sh may be not work

    # -f : Fail silently on server errors
    # -s : Silent or quit mode
    [[ -f "client-setup.sh" ]] || curl -fSLO https://raw.githubusercontent.com/CrunchyData/postgres-operator/v4.7.4/installers/kubectl/client-setup.sh > client-setup.sh
    chmod +x client-setup.sh
    ./client-setup.sh

    # Configuring pgouser
    echo "root:a" > ${HOME?}/.pgo/pgouser

    set +x

    if ! grep -q "pgo" ~/.bashrc ; then
        # TODO: Check port is available
        cat <<EOF | tee -a ~/.bashrc
 export PATH="$PATH:${HOME?}/.pgo"
 export PGOUSER="${HOME?}/.pgo/pgouser"
 export PGO_CA_CERT="${HOME?}/.pgo/client.crt"
 export PGO_CLIENT_CERT="${HOME?}/.pgo/client.crt"
 export PGO_CLIENT_KEY="${HOME?}/.pgo/client.key"
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

    rm -r /tmp/pgo
fi