# make a bucket to store API logs
resource "google_storage_bucket" "log_bucket_staging" {
  name                        = "example-log-bucket-staging"
  project                     = local.project
  location                    = "US"
  uniform_bucket_level_access = false
  force_destroy               = false
}

# redirect log entries to a bucket from a sink
resource "google_logging_project_sink" "logging_sink_staging" {
  name = "logging-sink-staging"

  # where to put the log entries (can also be a Pub/Sub, Database, or lots more)
  destination = "storage.googleapis.com/${google_storage_bucket.log_bucket_staging.name}"
  # this filter gives you all Cloud API calls
  filter = "logName=\"projects/${local.project}/logs/cloudaudit.googleapis.com%2Factivity\""

  # make a Service Account for this sink, instead of the default account
  unique_writer_identity = true
}
