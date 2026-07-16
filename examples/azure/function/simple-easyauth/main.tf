resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix    = random_string.suffix.result
  func_name = "func-easyauth-${var.environment}-${local.suffix}"

  common_tags = {
    SecurityControl = "Ignore"
    environment     = var.environment
    managedBy       = "terraform"
  }
}

# ── Resource Group ──────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-simple-easyauth-${var.environment}-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

# ── Storage Account (azurerm) ───────────────────────────────────────────────
# StorageV2 / Standard_LRS; connection string wired into AzureWebJobsStorage.

resource "azurerm_storage_account" "main" {
  name                     = "st${local.suffix}easyauth"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = local.common_tags
}

# ── Consumption App Service Plan (azurerm) ──────────────────────────────────

resource "azurerm_service_plan" "main" {
  name                = "asp-easyauth-${var.environment}-${local.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

# ── Entra App Registration (azuread) ────────────────────────────────────────
# The function app name is known ahead of time (via local.func_name) so the
# redirect URI can reference it without a circular dependency.

resource "azuread_application" "main" {
  display_name     = "app-simple-easyauth-${var.environment}-${local.suffix}"
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

# ── Function App (azapi) ─────────────────────────────────────────────────────
# Using azapi_resource so the function app kind and siteConfig are expressed
# directly against the ARM REST API without azurerm_linux_function_app.

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
        linuxFxVersion        = "Python|3.11"
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
# uses GET + merge + PUT semantics and emits no DELETE on destroy/replace.

resource "azapi_update_resource" "appsettings" {
  type      = "Microsoft.Web/sites/config@2023-12-01"
  name      = "appsettings"
  parent_id = azapi_resource.function_app.id

  body = {
    properties = {
      FUNCTIONS_EXTENSION_VERSION = "~4"
      FUNCTIONS_WORKER_RUNTIME    = "python"
      AzureWebJobsStorage         = azurerm_storage_account.main.primary_connection_string
    }
  }
}

# ── Easy Auth — authsettingsV2 (azapi_update_resource) ──────────────────────
# OIDC issuer points at the Entra tenant v2.0 endpoint; clientId is the app
# registration created above. unauthenticatedClientAction = RedirectToLoginPage
# is appropriate here since the function is a browser-accessible public example.

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
