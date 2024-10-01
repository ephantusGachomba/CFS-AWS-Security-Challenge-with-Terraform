output "webserver_sg" {
  value       = aws_security_group.webserver_sg.id
  description = "Webserver security group"
}

output "launch_template_id" {
  value       = aws_launch_template.frontend.id
  description = "Launch template id"
}