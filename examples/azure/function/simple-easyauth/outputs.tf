output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = azapi_resource.function_app.name
}

output "function_app_url" {
  description = "Default HTTPS URL of the Function App"
  value       = "https://${azapi_resource.function_app.name}.azurewebsites.net"
}

output "app_registration_client_id" {
  description = "Client ID (Application ID) of the Entra App Registration"
  value       = azuread_application.main.client_id
}
