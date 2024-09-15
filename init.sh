#!/bin/bash

sudo apt update && sudo apt upgrade -y

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

# Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
minikube start --driver=docker

# Microk8s
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube
microk8s status --wait-ready
microk8s enable dns && microk8s stop && microk8s start

# ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
nohup sh -c "kubectl port-forward svc/argocd-server -n argocd 9090:443" < /dev/null 2>&1
ARGO_PASS=$(argocd admin initial-password -n argocd | head -n 1)
argocd login localhost:8080 --username "admin" --password ${ARGO_PASS} --insecure

# Traefik
kubectl create namespace traefik
kubectl apply -n traefik -f https://raw.githubusercontent.com/traefik/traefik-helm-chart/main/traefik/templates/deployment.yaml
kubectl -n traefik patch svc traefik -p '{"spec": {"ports": [{"port": 80,"targetPort": 8181,"nodePort": 30881}]}}'
