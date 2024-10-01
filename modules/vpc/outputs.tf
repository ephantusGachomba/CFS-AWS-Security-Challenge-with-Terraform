# Export vpc id
output "vpc_id" {
  value       = aws_vpc.cloudforce_vpc.id
  description = "The vpc id"
}



output "cloudforce_publicA_id" {
  value = aws_subnet.cloudforce_publicA.id
}

output "cloudforce_publicB_id" {
  value = aws_subnet.cloudforce_publicB.id
}

output "cloudforce_privateA_id" {
  value = aws_subnet.cloudforce_privateA.id
}

output "cloudforce_privateB_id" {
  value = aws_subnet.cloudforce_privateB.id
}

output "cloudforce_privateC_id" {
  value = aws_subnet.cloudforce_privateC.id
}

output "cloudforce_privateD_id" {
  value = aws_subnet.cloudforce_privateD.id
}