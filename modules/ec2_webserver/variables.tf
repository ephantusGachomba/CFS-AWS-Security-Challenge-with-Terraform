# Declare the variable for the ELB security group ID
variable "elb_security_group_id" {
  description = "The security group ID associated with the public ELB"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ELB will be created"
  type        = string
}