#1. Web Server Security Group (appserver_sg):
resource "aws_security_group" "appserver_sg" {
  name        = "appserver_sg"
  description = "allow traffic from port 80/443 appserver elb & allow all outgoing traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "appserver_sg"
  }
}


# Inbound rule for HTTP traffic from the app server ELB (port 80)
resource "aws_security_group_rule" "allow_tcp_app_80" {
  type                     = "ingress"
  security_group_id        = aws_security_group.appserver_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Allow HTTP from app server ELB"
  source_security_group_id = var.appserver_elb_sg_id
}


# Inbound rule for HTTPS traffic from the app server ELB (port 443)
resource "aws_security_group_rule" "allow_tcp_app_443" {
  type                     = "ingress"
  security_group_id        = aws_security_group.appserver_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow HTTPS from app server ELB"
  source_security_group_id = var.appserver_elb_sg_id
}

# Inbound rule for HTTP traffic from the Web ELB (port 80)
resource "aws_security_group_rule" "allow_tcp_web_80" {
  type                     = "ingress"
  security_group_id        = aws_security_group.appserver_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Allow HTTP from public ELB"
  source_security_group_id = var.elb_security_group_id
}

# Inbound rule for HTTPS traffic from the Web ELB (port 443)
resource "aws_security_group_rule" "allow_tcp_web_443" {
  type                     = "ingress"
  security_group_id        = aws_security_group.appserver_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow HTTPS from public ELB"
  source_security_group_id = var.elb_security_group_id
}


# Allow all outbound traffic to internet(http)
resource "aws_security_group_rule" "allow_outbound_http" {
  type              = "egress"
  security_group_id = aws_security_group.appserver_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound traffic to internet"
}
