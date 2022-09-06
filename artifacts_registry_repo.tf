resource "google_artifact_registry_repository" "jenkins" {
  project = var.project_id
  provider = google-beta
  location      = var.gcp_region
  repository_id = "jenkins"
  description   = "Jenkins docker repository"
  format        = "DOCKER"
}