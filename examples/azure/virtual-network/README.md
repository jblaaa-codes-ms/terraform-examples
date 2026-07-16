# Azure Virtual Network Example

This example creates an Azure Resource Group, Virtual Network, and a default Subnet.

## Resources created

- `azurerm_resource_group`
- `azurerm_virtual_network`
- `azurerm_subnet`

## Usage

```bash
terraform init
terraform apply
```

## Inputs

| Name                  | Description                          | Type           | Default          |
|-----------------------|--------------------------------------|----------------|------------------|
| `location`            | Azure region                         | `string`       | `"East US"`      |
| `resource_group_name` | Name of the resource group           | `string`       | `"example-rg"`   |
| `vnet_name`           | Name of the virtual network          | `string`       | `"example-vnet"` |
| `address_space`       | Address space for the VNet           | `list(string)` | `["10.0.0.0/16"]`|
| `subnet_name`         | Name of the default subnet           | `string`       | `"default"`      |
| `subnet_prefix`       | Address prefix for the default subnet| `string`       | `"10.0.1.0/24"`  |
| `tags`                | Tags for all resources               | `map(string)`  | `{}`             |

## Outputs

| Name                  | Description                    |
|-----------------------|--------------------------------|
| `resource_group_name` | Name of the resource group     |
| `vnet_name`           | Name of the virtual network    |
| `vnet_id`             | ID of the virtual network      |
| `subnet_id`           | ID of the default subnet       |
