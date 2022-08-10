# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.gke_cluster
  location = var.gcp_region
  
  # Smallest possible node pool and immediately delete it to use separately managed Node Pool.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_network
  subnetwork = var.vpc_subnetwork
 
  master_authorized_networks_config {
  cidr_blocks {
    # Please add the CIDR IP address for authorized network
    cidr_block = "<IP_ADDR_RANGE_FOR_AUTHORIZED_NETWORK>"
    }
  }

  # Settings for private cluster 
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.32/28"
  }

  ip_allocation_policy {
    # IP range for pods
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range.0.range_name
    # IP range for services
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range.1.range_name
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "gke-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    machine_type = "n1-standard-1"
    tags         = ["gke-node"]
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = var.gke_cluster
  location = var.gcp_region
  project = var.project_id
}

provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Installing Jenkins controller using Helm chart
resource "helm_release" "jenkins" {
  depends_on = [google_container_node_pool.primary_nodes, google_container_cluster.primary]
  repository = "https://charts.bitnami.com/bitnami"
  name       = "jenkins"
  chart      = "jenkins"

  set {
    name  = "service.type"
    value = "NodePort"
  }
}