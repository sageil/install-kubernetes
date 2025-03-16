#!/usr/bin/env bash

echo "Pulling kubeadm required images"

sudo kubeadm config images pull
echo "Initializing cluster with cider 10.10.0.0/16"

sudo kubeadm init --pod-network-cidr=10.10.0.0/16

echo "Configuring kubectl"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installing Calico Oprator"

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/tigera-operator.yaml

echo "Setting up Calico custom resources"

# download calico custom resources and modify the default cidr to 10.10.0.0/16 instead of the default 192.168.0.0/16

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/custom-resources.yaml
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl apply -f custom-resources.yaml


echo "Installing Helm"

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

echo "Generating cluster join command"

kubeadm token create --print-join-command

echo "Done. Please execute the join command in all worker nodes"
