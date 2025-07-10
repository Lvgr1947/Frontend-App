#!/bin/bash

set -e

echo "Installing K3s without Traefik..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

echo "K3s installed."

echo "Copying kubeconfig to home directory..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

echo "Replacing localhost with EC2 public IP in kubeconfig..."
EC2_PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
sed -i "s/127.0.0.1/${EC2_PUBLIC_IP}/g" ~/.kube/config

echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Adding NGINX ingress controller via Helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

echo "Ingress NGINX installed."

echo " Setup complete. K3s is running on EC2 @ ${EC2_PUBLIC_IP}"
