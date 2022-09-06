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
      cidr_block = var.authorized_ip
    }
  }

  # Settings for private cluster 
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.32/28"
  }

  ip_allocation_policy {
    #ip range for pods
    cluster_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range.0.range_name
    #ip range for services
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
    machine_type    = "n1-standard-1"
    tags            = ["gke-node"]
    service_account = google_service_account.jenkins_gke.email
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = var.gke_cluster
  location = var.gcp_region
  project  = var.project_id
}
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Installing Jenkins controller using Helm chart

resource "helm_release" "jenkins" {
  depends_on       = [kubernetes_cluster_role_binding.terraform-gke-sa, google_container_node_pool.primary_nodes, google_container_cluster.primary]
  repository       = "https://charts.jenkins.io"
  name             = "jenkins"
  chart            = "jenkins"
  create_namespace = true
  namespace        = "jenkins-namespace"

}
data "google_service_account" "terraform-practice" {
  project    = var.project_id
  account_id = "<SERVICE_ACCOUNT_EMAIL>"
}


resource "kubernetes_cluster_role_binding" "terraform-gke-sa" {

  metadata {
    name = "cluster-admin-binding-terraform"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.google_service_account.terraform-practice.unique_id
  }
}

# Creating separate namespace for build executors

resource "kubernetes_namespace" "jenkins-build" {
  metadata {
    annotations = {
      name = "jenkins-build"
    }

    labels = {
      mylabel = "jenkins-build"
    }

    name = "jenkins-build"
  }
}

# Creating separate service account to allow access into jenkins-build

resource "kubernetes_service_account" "jenkins-build" {
  metadata {
    name = "jenkins-build"
    namespace = kubernetes_namespace.jenkins-build.id
  }
  secret {
    name = "${kubernetes_secret.jenkins-build.metadata.0.name}"
  }
}

# Creating service account secret for new namespace

resource "kubernetes_secret" "jenkins-build" {
  metadata {
    name = "jenkins-build"
  }
}

#Creating rolebinding for jenkins-build service account

resource "kubernetes_role_binding" "jenkins-admin-binding" {

  metadata {
    name = "jenkins-build-namespace-binding"
    namespace = "jenkins-build"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.jenkins-build.metadata.0.name}"
    namespace = "${kubernetes_namespace.jenkins-build.metadata.0.name}"
  }
}