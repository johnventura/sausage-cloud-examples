# tell terraform that we're using GCP
provider "google" {
  project = local.project
  region  = local.zone
}
