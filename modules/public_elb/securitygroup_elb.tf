#. ELB Security Group for Web (web_elb_sg):
#Allows incoming traffic from the cloudfront only
#Allows outbound traffic to the Web Servers.

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "web_elb_sg" {
  name        = "web_elb_sg"
  description = "Allow traffic from the internet & allow all outgoing traffic to webservers"
  vpc_id      = var.vpc_id

  tags = {
    Name = "web_elb_sg"
  }
}

# allow Inbound rule traffic from cloudfront only(80 --> 443) 
resource "aws_security_group_rule" "allow_inbound_webelb_80" {
  type              = "ingress"
  security_group_id = aws_security_group.web_elb_sg.id
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  #cidr_blocks       = ["0.0.0.0/0"]
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}

# allow Outbound rule traffic to webservers (80 --> 443) 
resource "aws_security_group_rule" "allow_outbound_https_to_web_servers" {
  type                     = "egress"
  security_group_id        = aws_security_group.web_elb_sg.id
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow outbound HTTPS traffic to web servers"
  source_security_group_id = var.webserver_sg
}