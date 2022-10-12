resource "google_dns_managed_zone" "sausage_private_zone" {
  name        = "sausage-private-zone"
  dns_name    = "tracker.sausage."
  description = "Sausage DNS zone"
  labels = {
    managed = "true"
  }

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.default_vpc.self_link
    }
  }
}
