variable "domain_name" {
  description = "domain name of elb"
  type        = string
}

variable "frontend_lb" {
  description = "aws_lb frontend_lb"
  type        = string
}
#[aws_lb.frontend_lb]