# define a new service account
resource "google_service_account" "sausage_service_account" {
  project      = local.project
  account_id   = "sausage"
  display_name = "Sausage Tracker Service Account"
}

# define an IAM policy that provides secret access to the Service Account ONLY
data "google_iam_policy" "sausage_private_policy" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_service_account.sausage_service_account.email}"
    ]
  }
  binding {
    role = "roles/secretmanager.viewer"
    members = [
      "serviceAccount:${google_service_account.sausage_service_account.email}"
    ]
  }
}

# assign the Service Account ownership of the secret
# attach the policy to the secret
resource "google_secret_manager_secret_iam_policy" "sausage_rds_iam_policy" {
  project   = local.project
  secret_id = data.google_secret_manager_secret_version.sql_passwd_sausage.id

  policy_data = data.google_iam_policy.sausage_private_policy.policy_data
}
