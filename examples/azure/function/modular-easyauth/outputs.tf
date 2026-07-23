output "resource_group_name" {
  description = "Name of the deployed Resource Group"
  value       = module.function_app.resource_group_name
}

output "function_app_name" {
  description = "Name of the deployed Function App"
  value       = module.function_app.function_app_name
}

output "function_app_url" {
  description = "Default HTTPS URL of the Function App"
  value       = module.function_app.function_app_url
}

output "app_registration_client_id" {
  description = "Client ID of the Entra App Registration"
  value       = module.function_app.app_registration_client_id
}

output "runtime" {
  description = "Runtime that was deployed"
  value       = module.function_app.runtime
}

output "linux_fx_version" {
  description = "Resolved linuxFxVersion string"
  value       = module.function_app.linux_fx_version
}
