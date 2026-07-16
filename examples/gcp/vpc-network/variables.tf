variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region where resources will be created."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "example-network"
}

variable "subnet_name" {
  description = "Name of the subnetwork."
  type        = string
  default     = "example-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnetwork."
  type        = string
  default     = "10.0.0.0/24"
}
