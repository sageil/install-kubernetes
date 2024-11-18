#!/usr/bin/env bash

echo "Disabling Swap"

sudo swapoff -a
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

echo "Configuring overlay and br_netfilter"

sudo cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "Preparing kubernetes-cri"

sudo cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

echo "Installing containerd"

sudo apt update && sudo apt install -y containerd

echo "Configuring containerd "
sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd

echo "Installing kubernetes Prerequisites"

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

echo "Installing kubernetes Dependencies"

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt install -y kubelet=1.31.2-1.1 kubeadm=1.31.2-1.1 kubectl=1.31.2-1.1
sudo apt-mark hold kubelet kubeadm kubectl

echo "Complete"
