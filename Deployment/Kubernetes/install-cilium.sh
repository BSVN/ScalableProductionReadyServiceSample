# ITNOA

#!/bin/bash

# Check cilium cli exist or not?
# https://stackoverflow.com/a/677212/1539100
if ! command -v cilium &> /dev/null ; then
    # https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
    curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
    rm cilium-linux-amd64.tar.gz{,.sha256sum}
fi

# TODO: Check if systemd version is greater than 245
# see GitHub https://github.com/cilium/cilium/issues/10645#issuecomment-949923696
echo 'net.ipv4.conf.lxc*.rp_filter = 0' > /etc/sysctl.d/99-override_cilium_rp_filter.conf
systemctl restart systemd-sysctl

# Check cilium does not install previously
cilium install

cilium status

# Validate that we cluster has proper network connectivity
cilium connectivity test