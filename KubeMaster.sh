#!/bin/bash
#Script for UBUNTU 22.04
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#Install the required packages for Docker:
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
#Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#Add the Docker repository:
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Update your package list again:
sudo apt update

#Install docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

#Start and enable the Docker service:

wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.9/cri-dockerd_0.3.9.3-0.ubuntu-bionic_amd64.deb

sudo dpkg -i cri-dockerd_0.3.9.3-0.ubuntu-bionic_amd64.deb
sudo systemctl start cri-docker
sudo systemctl enable cri-docker
sudo systemctl start docker
sudo systemctl enable docker

sudo apt-get update
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# NFS
sudo apt-get install -y nfs-common

# HELM
wget https://get.helm.sh/helm-v3.14.0-rc.1-linux-amd64.tar.gz
tar -zxvf  helm-v3.14.0-rc.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version

######## Only for Master !!!
#Start KubeMaster
sudo kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo systemctl restart kubelet
sudo systemctl enable kubelet
#sudo mkdir -p ~/.kube/ | sudo cp /etc/kubernetes/admin.conf ~/.kube/config | sudo chmod 755 ~/.kube/config
sudo kubeadm token create --print-join-command

#CNI - WEAVE install

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
#ami-08b91a65ed1075711


### After worker attach! 
#Reset CoreDNS

kubectl delete pod -n kube-system -l k8s-app=kube-dns
