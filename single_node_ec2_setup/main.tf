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

resource "aws_instance" "this" {
  count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.this.id]
  # user_data = file("./template/ec2-3.sh")
  key_name = "kubernetes-controlplane-euw2"
  tags = {
    Name = "Kubernetes-single-node-control-plane"
    iac = "Terraform"
    github_repo = "kubernetes-control-plane-setup"
  }
}
