

# Export the appserver ELB Security Group ID
output "appserver_elb_sg_id" {
  value       = aws_security_group.appserver_elb_sg.id
  description = "The security group ID associated with the appserver ELB"
}

output "appserverTG" {
  value = aws_lb_target_group.appserverTG.arn
}