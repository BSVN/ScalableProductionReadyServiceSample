# ITNOA
# Letting iptables see bridged traffic
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic

#!/bin/bash

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Check required ports
# https://kubernetes.io/docs/reference/ports-and-protocols/

# Installing runtime
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime

# https://askubuntu.com/a/1214268/101335
readonly os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')
if [ "$os_name" == "Ubuntu" ]
then
	echo "system is Ubuntu"

	# Update the apt package index and install packages needed to use the Kubernetes apt repository:
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl

	# Download the Google Cloud public signing key:
	sudo curl -fsSLo https://packages.cloud.google.com/apt/doc/apt-key.gpg 
	
	# Add key
	sudo apt-key add apt-key.gpg

	# Add the Kubernetes apt repository:
	# TODO: xenial must based on edition
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

	# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
	sudo apt-get update
	sudo apt-get install -y kubeadm kubelet kubectl docker.io
	sudo apt-mark hold kubeadm

	sudo systemctl enable --now kubelet

elif [ "$os_name" == "CentOS" ]
then
	echo "system is CentOS"
	cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

	# Set SELinux in permissive mode (effectively disabling it)
	sudo setenforce 0
	sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

	sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

	sudo systemctl enable --now kubelet
else
	echo "system is $os_name"
fi

# Enable bash completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubeadm completion bash)" >> ~/.bashrc

# TODO: How to add docker bash auto completion?
# echo "source <(docker completion bash)" >> ~/.bashrc