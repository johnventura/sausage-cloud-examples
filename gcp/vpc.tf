# we can define a VPC here, but we're using the VPC that came with the project
data "google_compute_network" "default_vpc" {
  name = local.network
}
