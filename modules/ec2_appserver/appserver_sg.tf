#1. Web Server Security Group (appserver_sg):
resource "aws_security_group" "appserver_sg" {
  name        = "appserver_sg"
  description = "allow traffic from port 443 appserver elb & allow all outgoing traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "appserver_sg"
  }
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
