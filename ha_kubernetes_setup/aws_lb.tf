data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_lb" "k8_lb" {
  name               = "k8-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "control_plane_nodes" {
  load_balancer_arn = aws_lb.k8_lb.arn
  port              = "6443"
  protocol          = "TCP"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#   alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_plane_nodes.arn
  }
}
resource "aws_lb_target_group" "control_plane_nodes" {
  name     = "control-plane-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  preserve_client_ip = false
}
resource "aws_lb_target_group_attachment" "control_plane_nodes" {
  count = length(aws_instance.control_plane_nodes[*].id)
  target_group_arn = aws_lb_target_group.control_plane_nodes.arn
  target_id        = aws_instance.control_plane_nodes[count.index].id
  port             = 6443
}
output "instance_ids" {
  value = aws_instance.control_plane_nodes[*].id
}