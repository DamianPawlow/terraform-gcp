variable "project_id" {
  description = "Project ID value"
  type        = string
}
variable "authorized_ip"{
  description = "IP address or range for private cluster authorized network"
  type = string
}
variable "bucket_name" {
  description = "Bucket name"
  type        = string
}
variable "gcp_region" {
  description = "Region name"
  type        = string
}
variable "ansible_client_zone" {
  description = "Zone name"
  type        = string
}

variable "gke_num_nodes" {
  description = "Number of gke nodes"
  default     = 1
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
variable "nat_gateway" {
  description = "NAT Gateway name"
  type        = string
}
variable "router" {
  description = "Cloud Router name"
  type        = string
}
variable "ansible_num_nodes" {
  description = "Number of Ansible client nodes"
  default = "2"
 }