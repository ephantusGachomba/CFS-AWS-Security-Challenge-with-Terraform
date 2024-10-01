
# Outputs for  S3 bucket details
output "s3_bucket_name" {
  value       = aws_s3_bucket.cloudfront_trail_bucket.bucket
  description = "S3 bucket for CloudFront logs"
}

#CloudTrail details
output "cloudtrail_arn" {
  value       = aws_cloudtrail.cloudfront_trail.arn
  description = "The ARN of the CloudTrail for CloudFront"
}


output "s3_bucket_arn" {
  value = aws_s3_bucket.cloudfront_trail_bucket.arn
}

output "s3_log_path" {
  value = "${aws_s3_bucket.cloudfront_trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
}
