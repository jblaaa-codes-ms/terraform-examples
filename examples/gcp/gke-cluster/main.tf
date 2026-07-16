resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  initial_node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  deletion_protection = false
}
