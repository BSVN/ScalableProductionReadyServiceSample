# ITNOA

#!/bin/bash

# Swap must be off for kubeadm work properly
if systemctl is-active swap.target --quiet; then
    readonly swap_name=$(systemctl show -p Requires --value swap.target)
    systemctl stop $swap_name
    systemctl mask $swap_name
fi

# Add this node to control plane node
sudo kubeadm init