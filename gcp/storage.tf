# build a new service bucket
resource "google_storage_bucket" "sausage_bucket" {
  name                        = "sausage_bucket"
  project                     = local.project
  location                    = "US"
  uniform_bucket_level_access = false
  force_destroy               = false
}

# assign READ access to the bucket
resource "google_storage_bucket_acl" "suasage_bucket_acl" {
  bucket = google_storage_bucket.sausage_bucket.name

  role_entity = [
    "READER:user-${google_service_account.sausage_service_account.email}"
  ]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_acl
