data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "control_plane_nodes" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data = count.index == 0 ? file("./template/ec2-control-plane-133.sh") : file("./template/ec2-control-plane-132.sh")
  # user_data = templatefile("./template/ec2-3.sh",{
  #   kube_version = "v1.32"
  # })
  key_name = "kubernetes-controlplane-euw2"
  tags = {
    Name = "Kubernetes-single-node-control-plane-${count.index + 1}"
    iac = "Terraform"
    github_repo = "kubernetes-control-plane-setup"
  }
}

resource "aws_instance" "worker_nodes" {
  count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data = file("./template/worker-node-128.sh")
  key_name = "kubernetes-controlplane-euw2"
  tags = {
    Name = "Kubernetes-worker-node-${count.index + 1}"
    iac = "Terraform"
    github_repo = "kubernetes-control-plane-setup"
    tier = "worker"
  }
}
