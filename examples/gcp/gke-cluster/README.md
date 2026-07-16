# GKE Cluster Example

This example provisions a basic Google Kubernetes Engine (GKE) cluster.

## Resources created

- `google_container_cluster`

## Usage

```bash
terraform init
terraform apply -var="project_id=my-gcp-project"
```

## Inputs

| Name           | Description                          | Type     | Default              |
|----------------|--------------------------------------|----------|----------------------|
| `project_id`   | GCP project ID                       | `string` | *(required)*         |
| `region`       | GCP region                           | `string` | `"us-central1"`      |
| `cluster_name` | Name of the GKE cluster              | `string` | `"example-cluster"`  |
| `node_count`   | Number of nodes in the default pool  | `number` | `2`                  |
| `machine_type` | Machine type for nodes               | `string` | `"e2-medium"`        |
| `network`      | VPC network to host the cluster      | `string` | `"default"`          |
| `subnetwork`   | VPC subnetwork to host the cluster   | `string` | `"default"`          |

## Outputs

| Name                    | Description                                    |
|-------------------------|------------------------------------------------|
| `cluster_name`          | Name of the GKE cluster                        |
| `cluster_endpoint`      | API server endpoint (sensitive)                |
| `cluster_ca_certificate`| Base64-encoded cluster CA certificate (sensitive)|
