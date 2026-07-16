# terraform-examples

A curated collection of Terraform examples organized by cloud provider and use case.

## Repository Structure

```
terraform-examples/
├── examples/
│   ├── aws/                  # Amazon Web Services examples
│   │   ├── ec2-instance/     # Standalone EC2 instance
│   │   ├── s3-bucket/        # S3 bucket with common configurations
│   │   └── vpc/              # VPC with subnets and routing
│   ├── azure/                # Microsoft Azure examples
│   │   ├── resource-group/   # Resource group
│   │   └── virtual-network/  # Virtual network with subnets
│   └── gcp/                  # Google Cloud Platform examples
│       ├── gke-cluster/      # Google Kubernetes Engine cluster
│       └── vpc-network/      # VPC network with subnetworks
└── modules/                  # Reusable Terraform modules
```

## Getting Started

Each example lives in its own folder and is self-contained. To use an example:

1. Navigate to the example directory:
   ```bash
   cd examples/aws/vpc
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. When finished, clean up resources:
   ```bash
   terraform destroy
   ```

## Example Layout

Every example follows the same file structure:

| File           | Purpose                                      |
|----------------|----------------------------------------------|
| `main.tf`      | Core resource definitions                    |
| `variables.tf` | Input variable declarations                  |
| `outputs.tf`   | Output value declarations                    |
| `versions.tf`  | Terraform and provider version constraints   |
| `README.md`    | Example-specific documentation               |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- Credentials configured for the relevant cloud provider

## Contributing

1. Create a new folder under the appropriate provider directory.
2. Follow the standard file layout described above.
3. Include a `README.md` that describes what the example does and any required variables.
4. Open a pull request.

## License

See [LICENSE](LICENSE).
