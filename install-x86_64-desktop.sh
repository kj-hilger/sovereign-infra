#!/bin/bash
# install-x64-desktop.sh

set -e

echo "--- 0. Pre-Installation Architecture Check ---"
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "❌ Error: This script is explicitly for x86_64 architectures. Detected: $ARCH"
    exit 1
fi

echo "--- 1. NVIDIA Driver & CUDA Toolkit Check ---"
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ Error: NVIDIA Drivers not found. Please install NVIDIA drivers and CUDA toolkit before running this bootstrap."
    exit 1
fi
echo "✅ NVIDIA Drivers detected:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader


echo "--- 2. Installing & Configuring Docker ---"
if ! command -v docker &> /dev/null; then
    echo "🔧 Installing Docker via official convenience script..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh

    # Allow current user to run Docker without sudo
    sudo usermod -aG docker "$USER"
    echo "⚠️ Docker installed. If you hit permission errors later, please log out and back in."
fi


echo "--- 3. Installing & Configuring NVIDIA Container Toolkit for Docker ---"
if ! dpkg -l | grep -q nvidia-container-toolkit; then
    echo "🔧 Adding NVIDIA Container Toolkit package repositories..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg --yes
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y nvidia-container-toolkit
fi

echo "🔧 Configuring Docker to use NVIDIA Container Runtime (Manual Override)..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
EOF
echo "🔄 Restarting Docker..."
sudo systemctl restart docker

echo "--- 4. Installing Minikube & Helm ---"
if ! command -v minikube &> /dev/null; then
    echo "🔧 Downloading and installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
fi

if ! command -v helm &> /dev/null; then
    echo "🔧 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi


echo "--- 5. Bootstrapping Minikube (High-Power Desktop Tuning) ---"
# We allocate 32GB RAM and 12 CPUs from the 64GB Desktop pool
# The key flag here is '--driver=docker' and '--container-runtime=containerd'
echo "🚀 Starting Minikube cluster with NVIDIA GPU support..."
minikube start \
  --driver=docker \
  --cpus=12 \
  --memory=32768 \
  --gpus=all \
  --addons=ingress

echo "⏳ Waiting for cluster core control plane..."
sleep 10


echo "--- 6. Enabling NVIDIA GPU Support via Minikube Addon ---"
# Minikube has an incredibly reliable, built-in addon for the NVIDIA device plugin
echo "🚀 Enabling Minikube NVIDIA GPU device plugin..."
minikube addons enable nvidia-gpu-device-plugin

echo "⏳ Verifying GPU allocatable allocation..."
sleep 15

if kubectl describe node | grep -A 8 "Allocatable" | grep -q "nvidia.com/gpu"; then
    echo -e "\033[32m✔ GPU registered successfully via Minikube Docker Driver!\033[0m"
    kubectl describe node | grep -A 8 "Allocatable" | grep "nvidia.com/gpu"
else
    echo -e "\033[31m❌ Error: GPU allocation failed. Check Minikube logs.\033[0m"
    exit 1
fi


echo "--- 7. Installing ArgoCD ---"
kubectl create namespace argocd || echo "⚠️ Namespace argocd already exists."
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Enable local Port-Forwarding/NodePort visibility for Desktop Web UI if needed
echo "🔧 Patching ArgoCD Server service to NodePort for local Desktop UI access..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'


echo "🎉 Sovereign Infra Minikube Desktop bootstrap complete!"
echo "💡 To easily open the Kubernetes Dashboard, run: minikube dashboard"
