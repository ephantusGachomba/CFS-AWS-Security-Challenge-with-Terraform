variable "vpc_id" {
  description = "The ID of the VPC where the ELB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

#
variable "webserver_sg_id" {
  description = "Inbound traffic from webservers"
  type        = string
}

variable "appserver_sg_id" {
  description = "Outbound traffic to appservers"
  type        = string
}