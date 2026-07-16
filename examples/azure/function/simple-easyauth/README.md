# simple-easyauth

A minimal, self-contained Terraform stack that deploys an Azure Function App with **Easy Auth (Entra ID / OIDC)** enabled. This is a deliberately simple public example — no private endpoints, no CMK, no AMPLS.

## What it creates

| Resource | Tool | Notes |
|---|---|---|
| Resource Group | azurerm | Tagged `SecurityControl=Ignore`, centralus |
| Storage Account | azurerm | StorageV2, Standard_LRS |
| App Service Plan | azurerm | Linux, Y1 (Consumption) |
| Entra App Registration | azuread | OIDC issuer, redirect URI wired |
| Entra Service Principal | azuread | Required for Easy Auth |
| Function App (Python 3.11) | **azapi** | `Microsoft.Web/sites`, kind `functionapp,linux` |
| App Settings | **azapi_update_resource** | Avoids 405 on singleton config child |
| authsettingsV2 | **azapi_update_resource** | Redirects unauthenticated users to Entra login |

## Easy Auth behaviour

- `requireAuthentication = true` — all requests must be authenticated.
- `unauthenticatedClientAction = RedirectToLoginPage` — browser users are redirected to the Entra login page.
- OIDC issuer: `https://login.microsoftonline.com/<tenant>/v2.0`
- Token store enabled; redirect URI: `https://<funcapp>.azurewebsites.net/.auth/login/aad/callback`

Verify with: `curl -I https://<funcapp>.azurewebsites.net/` — expect `HTTP/1.1 302` redirect to `login.microsoftonline.com`.

## Prerequisites

- Terraform ≥ 1.5
- `az login` with an account that has **Contributor** on the target subscription and **Application Administrator** (or **Application.ReadWrite.All**) on the Entra tenant.

## Usage

```bash
cd terraform/simple-easyauth

# optionally copy and edit the example vars
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform validate
terraform plan
terraform apply
```

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | RG name |
| `function_app_name` | Function App name |
| `function_app_url` | HTTPS URL |
| `app_registration_client_id` | Entra app client ID |

## Notes

- All resources are tagged `SecurityControl = "Ignore"` — this stack is intentionally public/open for demo purposes only.
- `azapi_update_resource` is used for `appsettings` and `authsettingsV2` because ARM singleton config children do not support DELETE (returns 405). This avoids Terraform destroy/replace failures.
- The function app name is computed before `apply` so the app registration redirect URI can reference it without a circular dependency.
