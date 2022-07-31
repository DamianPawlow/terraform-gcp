resource "google_compute_network" "vpc_network" {
  name = var.vpc_network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.vpc_subnetwork
  ip_cidr_range = "10.10.10.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
}
