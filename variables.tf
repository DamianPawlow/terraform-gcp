variable "project_id" {
  description = "Project ID value"
  type        = string
}
variable "bucket_name" {
  description = "bucket name"
  type        = string
}

variable "gcp_region" {
  description = "Region name"
  type        = string
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "vpc_network" {
    description = "VPC network name"
    type        = string
}

variable "vpc_subnetwork" {
    description = "VPC subnetwork name"
    type        = string
}

variable "gke_cluster" {
    description = "GKE cluster name"
    type        = string
}