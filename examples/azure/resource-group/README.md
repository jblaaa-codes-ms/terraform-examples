# Azure Resource Group Example

This example creates an Azure Resource Group.

## Resources created

- `azurerm_resource_group`

## Usage

```bash
terraform init
terraform apply -var="name=my-resource-group" -var="location=East US"
```

## Inputs

| Name       | Description                   | Type          | Default       |
|------------|-------------------------------|---------------|---------------|
| `location` | Azure region                  | `string`      | `"East US"`   |
| `name`     | Name of the resource group    | `string`      | `"example-rg"`|
| `tags`     | Tags for the resource group   | `map(string)` | `{}`          |

## Outputs

| Name                  | Description                       |
|-----------------------|-----------------------------------|
| `resource_group_name` | Name of the resource group        |
| `resource_group_id`   | ID of the resource group          |
| `location`            | Azure region of the resource group|
