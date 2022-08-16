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
