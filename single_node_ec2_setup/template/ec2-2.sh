#!/bin/bash
set -e

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "$LOG_FILE") 2>&1  # Log both stdout and stderr
echo "User data script started."

# Disable swap
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
if [ -f /swapfile ]; then
    sudo rm -f /swapfile
    echo "Deleted swap file."
fi
if free | grep -i swap | awk '{print $2}' | grep -q '^0$'; then
    echo "Swap successfully disabled."
else
    echo "Warning: Swap is still enabled!"
fi

# Install containerd
echo "Configuring sysctl settings..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward

echo "Installing containerd..."
sudo apt-get update && sudo apt-get install -y containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install kubelet, kubeadm, kubectl
echo "Installing Kubernetes components..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# Fetch EC2 private IP
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
if [[ -z "$PRIVATE_IP" ]]; then
    echo "Error: Unable to retrieve EC2 private IP."
    exit 1
fi
echo "EC2 Private IP: $PRIVATE_IP"

# Initialize Kubernetes
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --apiserver-advertise-address "$PRIVATE_IP" --pod-network-cidr 10.244.0.0/16

echo "User data script completed successfully."
