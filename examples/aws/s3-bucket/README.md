# S3 Bucket Example

This example creates a private S3 bucket with server-side encryption enabled and public access fully blocked.

## Resources created

- `aws_s3_bucket`
- `aws_s3_bucket_versioning`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_public_access_block`

## Usage

```bash
terraform init
terraform apply -var="bucket_name=my-unique-bucket-name-123"
```

## Inputs

| Name                | Description                      | Type          | Default       |
|---------------------|----------------------------------|---------------|---------------|
| `region`            | AWS region                       | `string`      | `"us-east-1"` |
| `bucket_name`       | Globally unique bucket name      | `string`      | *(required)*  |
| `versioning_enabled`| Enable versioning on the bucket  | `bool`        | `false`       |
| `tags`              | Additional tags                  | `map(string)` | `{}`          |

## Outputs

| Name                         | Description                          |
|------------------------------|--------------------------------------|
| `bucket_name`                | Name of the S3 bucket                |
| `bucket_arn`                 | ARN of the S3 bucket                 |
| `bucket_regional_domain_name`| Regional domain name of the bucket   |
