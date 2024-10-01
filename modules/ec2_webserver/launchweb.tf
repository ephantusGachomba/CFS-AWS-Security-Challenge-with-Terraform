#3. Create a launch template for web servers.
resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend"
  image_id      = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  network_interfaces {
    security_groups             = [aws_security_group.webserver_sg.id]
    associate_public_ip_address = true
  }

  # Using base64encode for the user_data script
  user_data = base64encode(file("${path.module}/frontenddata.sh"))


  lifecycle {
    create_before_destroy = true
  }
}

