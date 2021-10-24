# ITNOA

#!/bin/bash

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

# Add this node as worker node
# https://kubernetes.io/docs/reference/setup-tools/kubeadm
#
# Note: you have to generate token with `kubeadm token create` in control plane node
#       and find discovery-token-ca-cert-hash from ... (TODO: Find way to find discovery-token-ca-cert-hash)
# TODO: Make all parameter as variable
sudo kubeadm join 172.22.64.2:6443 --token "70jkdh.gx9oiqd7jno56nou" --discovery-token-ca-cert-hash sha256:b678d15c52e788bb012e75a60bc28dcf1732e80c4b2af976cb100b0fa4334b29

# If any error occured we have to use sudo kubeadm reset to clean filesystem
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/

# TODO: Check kubeadm join successfuly
# TODO: Check adding this node to control plane with kubectl get node