resource "aws_lb" "backend_lb" {
  name               = "appserver-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.appserver_elb_sg.id]
  subnets            = var.subnet_ids
  tags = {
    Environment = "test"
  }
}


resource "aws_lb_target_group" "appserverTG" {
  name     = "appserverTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    port                = 80
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "frontendListener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appserverTG.arn
  }
}
