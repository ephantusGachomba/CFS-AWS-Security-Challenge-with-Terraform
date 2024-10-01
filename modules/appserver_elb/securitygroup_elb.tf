#1. Web Server Security Group (webserver_sg):
#Allows traffic from the Web ELB(80)
resource "aws_security_group" "appserver_elb_sg" {
  name        = "appserver_elb_sg"
  description = "allow traffic from port 80 & allow all outgoing traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "appserver_elb_sg"
  }
}

# Inbound rule from the Web instances (private sub A & B)
resource "aws_security_group_rule" "allow_tcp_web_80" {
  type                     = "ingress"
  security_group_id        = aws_security_group.appserver_elb_sg.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "Allow from the Web instances"
  source_security_group_id = var.webserver_sg_id
}

# Allow all outbound traffic to app servers (private sub C & D)
resource "aws_security_group_rule" "allow_outbound_http" {
  type                     = "egress"
  security_group_id        = aws_security_group.appserver_elb_sg.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.appserver_sg_id
  description              = "Allow outbound traffic to app servers"
}
