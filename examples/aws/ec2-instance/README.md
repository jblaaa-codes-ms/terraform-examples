# EC2 Instance Example

This example provisions a single Amazon EC2 instance using the latest Amazon Linux 2 AMI.

## Resources created

- `aws_instance` — EC2 virtual machine

## Usage

```hcl
module "ec2" {
  source = "../../examples/aws/ec2-instance"

  region        = "us-east-1"
  instance_type = "t3.micro"
  name          = "my-instance"
}
```

Or use directly:

```bash
terraform init
terraform apply -var="name=my-instance"
```

## Inputs

| Name            | Description                             | Type     | Default             |
|-----------------|-----------------------------------------|----------|---------------------|
| `region`        | AWS region                              | `string` | `"us-east-1"`       |
| `instance_type` | EC2 instance type                       | `string` | `"t3.micro"`        |
| `ami_id`        | AMI ID (defaults to latest Amazon Linux 2) | `string` | `""`             |
| `name`          | Name tag for the instance               | `string` | `"example-instance"`|
| `tags`          | Additional tags                         | `map(string)` | `{}`           |

## Outputs

| Name         | Description                   |
|--------------|-------------------------------|
| `instance_id`| ID of the EC2 instance        |
| `public_ip`  | Public IP (if assigned)       |
| `private_ip` | Private IP of the instance    |
