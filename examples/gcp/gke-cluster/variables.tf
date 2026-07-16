variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region where the cluster will be created."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
  default     = "example-cluster"
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for the cluster nodes."
  type        = string
  default     = "e2-medium"
}

variable "network" {
  description = "VPC network name to host the cluster."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "VPC subnetwork name to host the cluster."
  type        = string
  default     = "default"
}
