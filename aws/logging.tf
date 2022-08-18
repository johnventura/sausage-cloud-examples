# establish a cloudtrail trail to log API calls
# consider logging to a bucket in a separate account to complicate anti-forensics
resource "aws_cloudtrail" "event_archive" {
  name                          = "event-archive"
  s3_bucket_name                = aws_s3_bucket.sausage_event_archive.id
  include_global_service_events = true
  is_multi_region_trail         = true
}
