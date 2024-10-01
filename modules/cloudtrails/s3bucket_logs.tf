
# Create S3 bucket for storing CloudTrail logs
resource "aws_s3_bucket" "cloudfront_trail_bucket" {
  bucket        = "cloudfront-trail-logs-bucket-efantus"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "restrict" {
  bucket = aws_s3_bucket.cloudfront_trail_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "restrict" {
  depends_on = [aws_s3_bucket_ownership_controls.restrict]

  bucket = aws_s3_bucket.cloudfront_trail_bucket.id
  acl    = "private"
}


# Get the AWS account ID
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# IAM policy to allow CloudTrail to log to the S3 bucket
data "aws_iam_policy_document" "cloudfront_trail_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudfront_trail_bucket.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudfront_trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    sid    = "AWSCloudFrontWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudfront_trail_bucket.arn}/cloudfront-logs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

# Apply the bucket policy for CloudTrail logging
resource "aws_s3_bucket_policy" "cloudfront_trail_bucket_policy" {
  bucket = aws_s3_bucket.cloudfront_trail_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_trail_policy.json
}

# Create CloudTrail to log CloudFront 
resource "aws_cloudtrail" "cloudfront_trail" {
  depends_on     = [aws_s3_bucket_policy.cloudfront_trail_bucket_policy]
  name           = "cloudfront-trail"
  s3_bucket_name = aws_s3_bucket.cloudfront_trail_bucket.id
  #s3_key_prefix                 = "AWSLogs/${data.aws_caller_identity.current.account_id}/cloudfront-logs"
  include_global_service_events = false
}