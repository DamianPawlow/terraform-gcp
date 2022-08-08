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
  }
}
provider "google" {
  #credentials defined in GOOGLE_APPLICATION_CREDENTIALS env variable
  #credentials = file("<NAME>.json")

  project = var.project_id
  region  = var.gcp_region
}
