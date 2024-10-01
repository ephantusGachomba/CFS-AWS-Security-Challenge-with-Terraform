# Output the CloudFront distribution domain name
output "cloudfront_domain_name" {
  value       = module.cloudfront.cloudfront_domain_name
  description = "The domain name of the CloudFront distribution"
}

#output elb dns
output "frontend_lb_dns_name"{
  value = module.public_elb.frontend_lb_dns_name
}
