# generate a random suffix, because you can't reuse SQL instance names
resource "random_id" "db_name_suffix_sausage" {
  byte_length = 4
}

# you might have to enable networking:
# gcloud services enable servicenetworking.googleapis.com --project=[YOUR PROJECT'S NAME] 
# define the Postgres instance here
resource "google_sql_database_instance" "sausage_tracker_backend" {
  name             = "sausage-tracker-sql-instance-${random_id.db_name_suffix_sausage.hex}"
  database_version = "POSTGRES_14"
  project          = local.project
  region           = local.region
  depends_on       = [google_service_networking_connection.sausage_db_vpc_connection]
  # use GCP secret storage to define password here
  root_password = data.google_secret_manager_secret_version.sql_passwd_sausage.secret_data
  settings {
    tier = "db-custom-1-4096" # format is db-custom-[number of CPUs]-[MB of RAM]
    ip_configuration {
      ipv4_enabled    = false # you DO NOT want a public IP
      private_network = "projects/${local.project}/global/networks/${local.network}"
      require_ssl     = true
    }
  }
}

# grab the secret from GCP secret manager
# passwords/secrets in code is a bad idea
data "google_secret_manager_secret_version" "sql_passwd_sausage" {
  provider = google
  project  = local.project
  secret   = "sausage-rds-password-prod"
}

# define an "admin" user for the Postgres
resource "google_sql_user" "sausage_tracker_backend_user" {
  name     = "admin"
  project  = local.project
  instance = google_sql_database_instance.sausage_tracker_backend.name
  password = data.google_secret_manager_secret_version.sql_passwd_sausage.secret_data
}

resource "google_compute_global_address" "sausage_db_private_ip_alloc" {
  name          = "sausage-db-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_vpc.id
}

resource "google_service_networking_connection" "sausage_db_vpc_connection" {
  network                 = data.google_compute_network.default_vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sausage_db_private_ip_alloc.name]
}

# you need a DNS name, because the IP is going to be assigned at db instance creation
resource "google_dns_record_set" "sausage_db_dns_name" {
  project      = local.project
  name         = "db.tracker.sausage."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.sausage_private_zone.name
  rrdatas      = [google_sql_database_instance.sausage_tracker_backend.ip_address[0].ip_address]
}
