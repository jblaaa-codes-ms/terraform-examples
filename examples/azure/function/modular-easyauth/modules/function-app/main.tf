resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix    = random_string.suffix.result
  func_name = "func-easyauth-${var.runtime}-${var.environment}-${local.suffix}"

  # Runtime → (linuxFxVersion, FUNCTIONS_WORKER_RUNTIME) mapping.
  # Adjust version numbers here if a newer version becomes the recommended default.
  runtime_defaults = {
    python     = { linux_fx_version = "Python|3.11",         worker_runtime = "python" }
    node       = { linux_fx_version = "Node|20",             worker_runtime = "node" }
    dotnet     = { linux_fx_version = "DOTNET-ISOLATED|8.0", worker_runtime = "dotnet-isolated" }
    java       = { linux_fx_version = "Java|17",             worker_runtime = "java" }
    powershell = { linux_fx_version = "PowerShell|7.4",      worker_runtime = "powershell" }
  }

  # Prefix strings for constructing a custom linuxFxVersion when runtime_version is set.
  runtime_prefix_map = {
    python     = "Python"
    node       = "Node"
    dotnet     = "DOTNET-ISOLATED"
    java       = "Java"
    powershell = "PowerShell"
  }

  linux_fx_version = (
    var.runtime_version != null
    ? "${local.runtime_prefix_map[var.runtime]}|${var.runtime_version}"
    : local.runtime_defaults[var.runtime].linux_fx_version
  )
  worker_runtime = local.runtime_defaults[var.runtime].worker_runtime

  common_tags = {
    SecurityControl = "Ignore"
    environment     = var.environment
    runtime         = var.runtime
    managedBy       = "terraform"
  }
}

# ── Resource Group ──────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-modular-easyauth-${var.runtime}-${var.environment}-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

# ── Storage Account ─────────────────────────────────────────────────────────

resource "azurerm_storage_account" "main" {
  name                     = "st${local.suffix}ea${var.runtime}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = local.common_tags
}

# ── Linux Consumption App Service Plan (Y1) ─────────────────────────────────

resource "azurerm_service_plan" "main" {
  name                = "asp-easyauth-${var.runtime}-${var.environment}-${local.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

# ── Entra App Registration ───────────────────────────────────────────────────
# func_name is computed from locals (no circular dependency).

resource "azuread_application" "main" {
  display_name     = "app-modular-easyauth-${var.runtime}-${var.environment}-${local.suffix}"
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = ["https://${local.func_name}.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
      id_token_issuance_enabled     = true
      access_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

# ── Function App (azapi_resource) ───────────────────────────────────────────

resource "azapi_resource" "function_app" {
  type      = "Microsoft.Web/sites@2023-12-01"
  name      = local.func_name
  location  = azurerm_resource_group.main.location
  parent_id = azurerm_resource_group.main.id
  tags      = local.common_tags

  body = {
    kind = "functionapp,linux"
    properties = {
      serverFarmId = azurerm_service_plan.main.id
      httpsOnly    = true
      siteConfig = {
        linuxFxVersion        = local.linux_fx_version
        ftpsState             = "Disabled"
        minTlsVersion         = "1.2"
        http20Enabled         = true
        use32BitWorkerProcess = false
      }
    }
  }

  response_export_values = ["properties.defaultHostName"]
}

# ── App Settings (azapi_update_resource) ────────────────────────────────────
# ARM singleton config children do NOT support DELETE — azapi_update_resource
# uses GET + merge + PUT semantics, no DELETE on destroy/replace.

resource "azapi_update_resource" "appsettings" {
  type      = "Microsoft.Web/sites/config@2023-12-01"
  name      = "appsettings"
  parent_id = azapi_resource.function_app.id

  body = {
    properties = {
      FUNCTIONS_EXTENSION_VERSION = "~4"
      FUNCTIONS_WORKER_RUNTIME    = local.worker_runtime
      AzureWebJobsStorage         = azurerm_storage_account.main.primary_connection_string
    }
  }
}

# ── Easy Auth — authsettingsV2 (azapi_update_resource) ──────────────────────
# requireAuthentication=true, RedirectToLoginPage, OIDC issuer v2.0 endpoint.

resource "azapi_update_resource" "auth_v2" {
  type      = "Microsoft.Web/sites/config@2023-12-01"
  name      = "authsettingsV2"
  parent_id = azapi_resource.function_app.id

  body = {
    properties = {
      globalValidation = {
        requireAuthentication       = true
        unauthenticatedClientAction = "RedirectToLoginPage"
      }
      identityProviders = {
        azureActiveDirectory = {
          enabled = true
          registration = {
            clientId     = azuread_application.main.client_id
            openIdIssuer = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
          }
          validation = {
            allowedAudiences = ["api://${azuread_application.main.client_id}"]
          }
        }
      }
      login = {
        tokenStore = {
          enabled = true
        }
      }
      platform = {
        enabled        = true
        runtimeVersion = "~1"
      }
    }
  }

  depends_on = [azapi_update_resource.appsettings]
}
