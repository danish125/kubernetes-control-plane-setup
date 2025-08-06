#!/bin/bash
set -e
echo "Welcome"
exec > /dev/null  # Redirect stdout to /dev/null (hide success output)
exec 2> >(while read line; do echo "[ERROR] $line"; done)  # Only print stderr with [ERROR] prefix
echo "Disabling swap..."

# Turn off swap immediately
sudo swapoff -a

# Remove swap entry from /etc/fstab
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Delete swap file if it exists
if [ -f /swapfile ]; then
    sudo rm -f /swapfile
    echo "Deleted swap file."
fi

# Verify swap is disabled
if free | grep -i swap | awk '{print $2}' | grep -q '^0$'; then
    echo "Swap is successfully disabled."
else
    echo "Warning: Swap is still enabled!"
fi
#install containerd
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
sysctl net.ipv4.ip_forward

sudo apt-get install containerd
containerd config default > /etc/containerd/config.toml
sudo sed -i 's/systemd_cgroup *= *false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd


#Install kubectl, kubeadm , kubelet
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet


# Get the private IP address of the EC2 instance
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Verify the private IP is fetched
if [[ -z "$PRIVATE_IP" ]]; then
    echo "Error: Unable to retrieve EC2 private IP."
    exit 1
fi

echo "EC2 Private IP: $PRIVATE_IP"

# Run kubeadm init with the correct private IP
sudo kubeadm init --apiserver-advertise-address "$PRIVATE_IP" --pod-network-cidr 10.244.0.0/16


