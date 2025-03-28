resource "aws_security_group" "this" {
  name        = "k8-cp-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = local.inbound_rules
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = try(each.value.ip_protocol,"tcp")
  to_port           = try(each.value.to_port,each.value.from_port)
  description       = try(each.value.description,null)
}

# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.this.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
locals {
    inbound_rules = {
        rule_1 = {
            cidr_ipv4 = "0.0.0.0/0"
            from_port = "22"
            # ip_protocol = "tcp"
            # to_port = "22"
            description = "ssh from anywhere"
        },
        rule_2 = {
            cidr_ipv4 = data.aws_vpc.selected.cidr_block
            from_port = "6443"
            description = "allow kube-apiserver from vpc cidr"
            # ip_protocol = ""
            # to_port = ""
        }
        # rule_3 = {
        #     cidr_ipv4 = data.aws_vpc.selected.cidr_block
        #     from_port = "6443"
        #     description = "allow kube-apiserver from vpc cidr"
        #     # ip_protocol = ""
        #     # to_port = ""
        # }
        # rule_4 = {
        #     cidr_ipv4 = data.aws_vpc.selected.cidr_block
        #     from_port = "6443"
        #     description = "allow kube-apiserver from vpc cidr"
        #     # ip_protocol = ""
        #     # to_port = ""
        # }

    }
}
# variable "vpc_id" {}
data "aws_region" "current" {}
output "region" {
  value = data.aws_region.current.name
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}