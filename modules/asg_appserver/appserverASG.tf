resource "aws_autoscaling_group" "backendASG" {
  name     = "backendASG"
  min_size = 2
  max_size = 6

  health_check_type = "EC2"

  vpc_zone_identifier = var.subnet_ids


  target_group_arns = [var.target_group_arn]

  #specify the launch template that contains the configuration for the EC2 instances you want to create
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.launch_template_id
        #aws_launch_template.backend.id
      }

    }
  }
  tag {
    key                 = "Name"
    value               = "backendInstance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asgpolicy" {
  name                   = "asgpolicy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backendASG.name

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 25.0
  }
}