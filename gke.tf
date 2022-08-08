# GKE cluster
resource "google_container_cluster" "primary" {
  depends_on = [
    google_compute_network.vpc_network,
    google_compute_subnetwork.subnet,
  ]
  name     = var.gke_cluster
  location = var.gcp_region
  
# Smallest possible node pool and immediately delete it to use separately managed Node Pool.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_network
  subnetwork = var.vpc_subnetwork

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