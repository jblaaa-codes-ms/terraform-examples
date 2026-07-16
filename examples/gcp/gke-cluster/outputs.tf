output "cluster_name" {
  description = "Name of the GKE cluster."
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster API server."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded public certificate for the cluster CA."
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}
