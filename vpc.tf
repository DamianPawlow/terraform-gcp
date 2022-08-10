resource "google_compute_network" "vpc_network" {
  name = var.vpc_network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.vpc_subnetwork
  ip_cidr_range = "10.1.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
  
  secondary_ip_range { 
    range_name = "jenkins-pods" 
    ip_cidr_range = "10.2.0.0/20" 
    }
    
  secondary_ip_range { 
    range_name = "jenkins-services" 
    ip_cidr_range = "10.3.0.0/20"
    }
}

resource "google_compute_router" "router" {
  name    = var.router
  region  = var.gcp_region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_router" {
  name                               = var.nat_gateway
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}