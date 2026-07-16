# GCP VPC Network Example

This example creates a custom-mode VPC network and a regional subnetwork in Google Cloud.

## Resources created

- `google_compute_network`
- `google_compute_subnetwork`

## Usage

```bash
terraform init
terraform apply -var="project_id=my-gcp-project"
```

## Inputs

| Name           | Description                     | Type     | Default              |
|----------------|---------------------------------|----------|----------------------|
| `project_id`   | GCP project ID                  | `string` | *(required)*         |
| `region`       | GCP region                      | `string` | `"us-central1"`      |
| `network_name` | Name of the VPC network         | `string` | `"example-network"`  |
| `subnet_name`  | Name of the subnetwork          | `string` | `"example-subnet"`   |
| `subnet_cidr`  | CIDR range for the subnetwork   | `string` | `"10.0.0.0/24"`      |

## Outputs

| Name           | Description              |
|----------------|--------------------------|
| `network_name` | Name of the VPC network  |
| `network_id`   | ID of the VPC network    |
| `subnet_name`  | Name of the subnetwork   |
| `subnet_id`    | ID of the subnetwork     |
