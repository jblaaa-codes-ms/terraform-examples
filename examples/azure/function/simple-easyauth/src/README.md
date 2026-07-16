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

## Function code

The Python v2 source lives in [`src/`](src/README.md). It contains a single HTTP trigger (`GET /api/hello`) that returns `{"message": "hello-world"}`.

See [`src/README.md`](src/README.md) for local development, `local.settings.json`, and testing behind Easy Auth.

## Deploy the Python code to Azure

Run these commands **from the `src/` folder** after `terraform apply` completes.
Resource names are shown as concrete examples; get the canonical values for your environment with `terraform output` (keys: `function_app_name`, `resource_group_name`).

### Option A: Azure Functions Core Tools

```bash
cd src
func azure functionapp publish func-easyauth-dev-hevmg3 --python
```

`func publish` performs a remote Oryx build, packages the result as a squashfs artifact, uploads it to blob storage, and sets `WEBSITE_RUN_FROM_PACKAGE` to the blob URL automatically.

---

### Option B: az CLI zip deploy (no Core Tools required)

**Step 1 — Enable remote build**

Tell the SCM endpoint to run Oryx so `requirements.txt` dependencies are installed on the server:

```bash
az functionapp config appsettings set \
  -g rg-simple-easyauth-dev-hevmg3 \
  -n func-easyauth-dev-hevmg3 \
  --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

**Step 2 — Create a deployment zip** (run from the `src/` folder)

*PowerShell:*
```powershell
Compress-Archive -Path function_app.py, requirements.txt, host.json `
  -DestinationPath deploy.zip -Force
```

*Bash / Linux / macOS:*
```bash
zip deploy.zip function_app.py requirements.txt host.json
```

> `.venv/`, `__pycache__/`, and `local.settings.json` are excluded — they are dev-only and listed in `.funcignore`.

**Step 3 — Deploy**

```bash
az functionapp deployment source config-zip \
  -g rg-simple-easyauth-dev-hevmg3 \
  -n func-easyauth-dev-hevmg3 \
  --src deploy.zip
```

> ⚠️ **Gotcha:** do **not** manually set `WEBSITE_RUN_FROM_PACKAGE=1` with an empty or missing package — that prevents the function host from starting on Linux Consumption. `config-zip` manages `WEBSITE_RUN_FROM_PACKAGE` internally after a successful deploy.

**Verify the function is registered**

```bash
# Remove the local zip
Remove-Item deploy.zip   # PowerShell
# rm deploy.zip          # Bash

az functionapp function list \
  -g rg-simple-easyauth-dev-hevmg3 \
  -n func-easyauth-dev-hevmg3 \
  -o table
```

Expected output includes `hello` with language `python` and invoke URL `https://func-easyauth-dev-hevmg3.azurewebsites.net/api/hello`.

> **Easy Auth:** unauthenticated requests return `302` (browser) or `401` (API client) — this is correct and expected. Use `az functionapp function list` to confirm registration without needing an authenticated call.

## Notes

- All resources are tagged `SecurityControl = "Ignore"` — this stack is intentionally public/open for demo purposes only.
- `azapi_update_resource` is used for `appsettings` and `authsettingsV2` because ARM singleton config children do not support DELETE (returns 405). This avoids Terraform destroy/replace failures.
- The function app name is computed before `apply` so the app registration redirect URI can reference it without a circular dependency.
