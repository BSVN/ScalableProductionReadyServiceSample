#!/bin/bash

# ITNOA

if systemctl is-active kubelet --quiet; then
    echo "kubelet is active, so add this node to control plane must be manually"
    exit 0
fi

# TODO: Get these variable from input
readonly api_server_address="172.22.64.2"
readonly control_plane_address=$api_server_address

# Swap must be off for kubeadm work properly
if systemctl is-active swap.target --quiet; then
    readonly swap_name=$(systemctl show -p Requires --value swap.target)
    systemctl stop $swap_name
    systemctl mask $swap_name
fi

# If kubelet version is 1.22 or greater we must to change docker driver
# https://sysnet4admin.gitbook.io/k8s/trouble-shooting/cluster-build/kubelet-is-not-properly-working-on-1.22-version
#
# TODO: Check kubelet version is 1.22 and docker cgroup driver is cgroupfs like docker system info | grep -i driver
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload && systemctl restart docker

# Add this node to control plane node
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
sudo kubeadm init --apiserver-advertise-address $api_server_address --apiserver-bind-port 6443 --control-plane-endpoint $control_plane_address

# If any error occured we have to use sudo kubeadm reset to clean filesystem
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/

# TODO: Check kubeadm init run successfuly
# TODO: Check adding this node to control plane with kubectl get node

# Check user is root or not
# https://www.cyberciti.biz/tips/shell-root-user-check-script.html
if [[ $EUID -ne 0 ]]; then
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
else
    export KUBECONFIG=/etc/kubernetes/admin.conf
fi