#!/bin/bash
# install-arm64-k3s.sh
# Optimized for NVIDIA Jetson Orin Nano (8GB RAM)
set -e

echo "--- 1. Installing NVIDIA Container Runtime ---"
# Ensure K3s/containerd can interface with Jetson's hardware-accelerated drivers
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
# Configure the runtime for the container engine
sudo nvidia-ctk runtime configure --runtime=docker

echo "--- 2. Installing K3s (Resource-Optimized for 8GB RAM) ---"
# Disabling Traefik and Service-LB to save memory for AI & BPMN workloads.
# Using --container-runtime-endpoint to link with the NVIDIA-enabled containerd socket.
curl -sfL https://get.k3s.io | sh -s - \
  --container-runtime-endpoint unix:///var/run/containerd/containerd.sock \
  --disable traefik \
  --disable servicelb

# Kubeconfig Setup: Securely export cluster credentials for the local user
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

echo "--- 3. Enabling NVIDIA GPU Support in Kubernetes ---"
# Install NVIDIA Device Plugin via Helm (Critical for Ollama GPU passthrough)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade --install nvdp nvdp/kubernetes-device-plugin \
  --namespace kube-system \
  --set nvidiaDriverRoot=/usr/lib/aarch64-linux-gnu/nvidia

echo "--- 4. Installing ArgoCD (Core Mode recommended for 8GB) ---"
# NOTE: To save even more RAM, consider 'ArgoCD Core' in the future.
# For now, we deploy the standard manifests into the argocd namespace.
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "--- 5. Verification ---"
echo "Waiting for GPU resource registration (approx. 10s)..."
sleep 10
# Verify if the Orin Nano GPU is visible as an allocatable resource
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu

echo "--- Setup Complete ---"
echo "Reminder: Monitor RAM usage carefully as Ollama and Camunda share 8GB Unified Memory."