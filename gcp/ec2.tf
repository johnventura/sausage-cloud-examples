# choose your base OS image here. `gcloud compute images list` to see a list of public images
data "google_compute_image" "ubuntu_2204" {
  family  = "ubuntu-pro-2204-lts"
  project = "ubuntu-os-pro-cloud"
}

# encode the cloud-init data
data "cloudinit_config" "cloud_init_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = local.cloudinit_configure
  }
}

# define the EC2 autoscaler
resource "google_compute_autoscaler" "sausage_autoscaler" {
  name   = "sausage-autoscaler"
  zone   = local.zone
  target = google_compute_instance_group_manager.sausage_igm.id

  autoscaling_policy {
    max_replicas    = 1 # only need 1 host for this purpose
    min_replicas    = 1
    cooldown_period = 60 # health checks during boot leads to boot loops
  }
}

# define the Instance Group Manager
resource "google_compute_instance_group_manager" "sausage_igm" {
  name = "sausage-igm"
  zone = local.zone

  version {
    instance_template = google_compute_instance_template.sausage_instance_template.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.sausage_target_pool.id]
  base_instance_name = "sausage-tracker"
}

# this is where we define what the instance(s) will be like
resource "google_compute_instance_template" "sausage_instance_template" {
  name           = "sausage-instance-template"
  machine_type   = "e2-medium"
  region         = local.region
  can_ip_forward = false

  tags = ["tracker"]

  disk {
    source_image = data.google_compute_image.ubuntu_2204.id
  }

  network_interface {
    network            = local.network
    subnetwork_project = local.project
    subnetwork         = local.subnet
  }

  service_account {
    email  = "sausage@${local.project}.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-ro"] # limit this
  }

  metadata = {
    user-data = data.cloudinit_config.cloud_init_config.rendered
  }
}

# we need a target pool
resource "google_compute_target_pool" "sausage_target_pool" {
  name   = "sausage-target-pool"
  region = local.region
}

# allow incoming traffic
resource "google_compute_firewall" "tracker_iap_sg" {
  name    = "tracker-iap-ingress"
  network = local.network
  project = local.project
  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  # Ingress IPs are documented, so we do not forget later
  # 35.235.240.0/20 is needed for Google IAP proxy
  # 9.9.9.0/24 is John's home left here as an example
  source_ranges = ["35.235.240.0/20", "9.9.9.0/24"]

  # all instances tagged as "tracker" will be accessible
  target_tags = ["tracker"]
}
