# VPC Example

This example creates a VPC with public and private subnets spread across multiple availability zones, along with an Internet Gateway and a public route table.

## Resources created

- `aws_vpc`
- `aws_internet_gateway`
- `aws_subnet` (public × 2, private × 2)
- `aws_route_table` (public)
- `aws_route_table_association`

## Usage

```bash
terraform init
terraform apply
```

## Inputs

| Name                   | Description                          | Type           | Default                              |
|------------------------|--------------------------------------|----------------|--------------------------------------|
| `region`               | AWS region                           | `string`       | `"us-east-1"`                        |
| `vpc_cidr`             | CIDR block for the VPC               | `string`       | `"10.0.0.0/16"`                      |
| `public_subnet_cidrs`  | CIDR blocks for public subnets       | `list(string)` | `["10.0.1.0/24","10.0.2.0/24"]`      |
| `private_subnet_cidrs` | CIDR blocks for private subnets      | `list(string)` | `["10.0.101.0/24","10.0.102.0/24"]`  |
| `name`                 | Name prefix for all resources        | `string`       | `"example"`                          |
| `tags`                 | Additional tags                      | `map(string)`  | `{}`                                 |

## Outputs

| Name                  | Description                    |
|-----------------------|--------------------------------|
| `vpc_id`              | ID of the VPC                  |
| `public_subnet_ids`   | IDs of the public subnets      |
| `private_subnet_ids`  | IDs of the private subnets     |
| `internet_gateway_id` | ID of the Internet Gateway     |
