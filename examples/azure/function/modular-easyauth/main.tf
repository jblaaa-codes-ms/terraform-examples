module "function_app" {
  source = "./modules/function-app"

  environment     = var.environment
  location        = var.location
  tenant_id       = var.tenant_id
  runtime         = var.runtime
  runtime_version = var.runtime_version
}
