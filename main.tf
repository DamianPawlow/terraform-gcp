terraform {
  backend "gcs" {
    bucket  = "<GCS_BUCKET_NAME>"
    prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.21.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
provider "google" {

  project = var.project_id
  region  = var.gcp_region
}
resource "google_service_account" "jenkins_gke" {
  account_id = "jenkins-gke"
  display_name = "jenkins-gke"
}

resource "google_project_iam_member" "gke_nodes_binding" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.jenkins_gke.email}"
}
