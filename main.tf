terraform {
  backend "gcs" {
    bucket  = "<BUCKET_NAME"
    prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.9.0"
    }
  }
}
provider "google" {
  #credentials defined in GOOGLE_APPLICATION_CREDENTIALS env variable
  #credentials = file("<NAME>.json")

  project = var.project_id
  region  = var.gcp_region
}
