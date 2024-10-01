output "appserver_sg" {
  value       = aws_security_group.appserver_sg.id
  description = "Appserver security group"
}

output "launch_template_id" {
  value       = aws_launch_template.backend.id
  description = "Launch template id"
}