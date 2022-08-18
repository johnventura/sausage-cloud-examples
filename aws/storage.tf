# make the bucket here
resource "aws_s3_bucket" "sausage_bucket" {
  bucket = "sausage-bucket"
}

# define the bucket as "private" (public is bad) 
resource "aws_s3_bucket_acl" "sausage_bucket_acl" {
  bucket = aws_s3_bucket.sausage_bucket.id
  acl    = "private" # more complicated policies are possible
}

# set access for the bucket
resource "aws_s3_bucket_public_access_block" "sausage_bucket_block" {
  bucket = aws_s3_bucket.sausage_bucket.id

  # set all these settings to true to disable ALL public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################################################
# This section demonstrates how to set up Cloudtrail for event logging. #
# This practice is optional, but it is a really good idea for forensics #
# and general debugging.                                                #
#########################################################################

# bucket for AWS CloudTrail Event logging
resource "aws_s3_bucket_acl" "sausage_event_acl" {
  bucket = aws_s3_bucket.sausage_event_archive.id
  acl    = "private"
}

# get our current account id
data "aws_caller_identity" "current" {}

# access policy needed so Cloudtrail can write events
resource "aws_s3_bucket_policy" "sausage_event_archive_policy" {
  bucket = aws_s3_bucket.sausage_event_archive.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.sausage_event_archive.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.sausage_event_archive.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
