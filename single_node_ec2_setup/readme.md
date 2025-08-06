#disable swap
sudo swapoff -a
/etc/fstab
systemd.swap


Enable IPv4 packet forwarding 
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
sysctl net.ipv4.ip_forward


apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
...
cgroupDriver: systemd





Questions to Practice:

0
Create Kubeadm cluster using containerd container runtime


1
Install COntainer Runtime (containerd) with default values (it will be running as cgroupfs by default) 
Run kubectl (it will be running as systemd by default)
Check logs and fix

2
Install Container Runtime (containerd) with default values (change cgroup to systemd) 

Run kubectl (change cgroup to cgroupfs)
check logs and fix

3
Create Kubeadm cluster using cri-o container runtime

4
Create Kubeadm cluster using Docker Engine container runtime

5
Create Kubeadm cluster using MCR container runtime

6
try to join kubeadm cluster with 1.29 kubelet when server controlplane1 running on 1.33 and controlplane running on 1.32

7
try to join kubeadm cluster with 1.29 kubelet when server controlplane1 running on 1.32 and controlplane running on 1.32


7
try to join kubeadm cluster with 1.29 kubelet when server controlplane1 running on 1.32 and controlplane running on 1.33


8
Upgrade HA kubeadm cluster from 1.xx to 1.xx+1

