# modular-easyauth

Modularized, multi-runtime Azure Function App with Entra ID Easy Auth. A single reusable Terraform module deploys a complete stack (resource group, storage account, Linux Consumption plan, Entra app registration, Function App, app settings, authsettingsV2) for any supported runtime by passing `runtime` as an input variable.

## Module architecture

```
modular-easyauth/
├── main.tf                  # root stack — calls module once
├── variables.tf             # root inputs (subscription_id, tenant_id, location, environment, runtime, runtime_version)
├── providers.tf             # azurerm ~>4, azapi ~>2, azuread ~>3, random ~>3.6
├── outputs.tf               # proxies module outputs
├── <runtime>.tfvars         # one per runtime (python, node, dotnet, java, powershell)
├── terraform.tfvars.example
├── .gitignore
├── modules/
│   └── function-app/
│       ├── main.tf          # all Azure resources; runtime → linuxFxVersion mapping in locals
│       ├── variables.tf     # module inputs
│       ├── outputs.tf       # resource_group_name, function_app_name, function_app_url, etc.
│       └── versions.tf      # required_providers (needed so TF resolves azure/azapi correctly)
└── src/
    ├── python/              # Python v2 programming model
    ├── node/                # Node.js v4 programming model
    ├── dotnet/              # .NET 8 isolated worker
    ├── java/                # Java 17 (Maven required to build)
    └── powershell/          # PowerShell v1 model (function.json)
```

## Module inputs

| Variable | Type | Default | Description |
|---|---|---|---|
| `environment` | string | `"dev"` | Short label (dev/test/prod) |
| `location` | string | `"centralus"` | Azure region |
| `tenant_id` | string | required | Entra tenant ID for OIDC issuer |
| `runtime` | string | required | One of: `node`, `java`, `dotnet`, `python`, `powershell` |
| `runtime_version` | string | `null` | Optional version override (e.g. `"3.12"` for Python) |

## Runtime mapping

| `runtime` | `linuxFxVersion` | `FUNCTIONS_WORKER_RUNTIME` |
|---|---|---|
| `python` | `Python\|3.11` | `python` |
| `node` | `Node\|20` | `node` |
| `dotnet` | `DOTNET-ISOLATED\|8.0` | `dotnet-isolated` |
| `java` | `Java\|17` | `java` |
| `powershell` | `PowerShell\|7.4` | `powershell` |

> **EOL notice (2026-07):** Node 20 reached EOL 2026-04-29; PowerShell 7.4 and .NET 8 reach EOL 2026-11-09. Consider upgrading to Node 22, PowerShell 7.6, or .NET 10 when those versions are available on Linux Consumption. Pass `runtime_version = "22"` (etc.) to override without editing the module.

## Prerequisites

- Terraform ≥ 1.5
- Azure CLI authenticated (`az login`)
- Account must be able to create Entra app registrations (Application Administrator or equivalent)
- Azure Functions Core Tools v4 (`func --version`)

## Quickstart

```powershell
# 1. Initialize (once — providers are shared across all runtimes)
cd terraform\modular-easyauth
terraform init

# 2. Apply for a specific runtime
terraform apply -auto-approve "-var-file=python.tfvars"

# 3. Deploy the function code (see per-runtime section below)

# 4. Destroy when done
terraform destroy -auto-approve "-var-file=python.tfvars"
```

## Deploy each runtime

### Python

```powershell
cd src\python
func azure functionapp publish <function_app_name> --python
```

### Node.js

Node.js v4 programming model. After deploy, run a trigger sync because the v4 model registers functions programmatically (not via `function.json`) and the ARM API may need a sync:

```powershell
cd src\node
npm install
# Include node_modules in the zip — remote Oryx build not needed for small packages
Compress-Archive -Path index.js, package.json, package-lock.json, host.json, src, node_modules -DestinationPath deploy.zip -Force
az functionapp deployment source config-zip -g <rg> -n <app> --src deploy.zip
# Force ARM trigger sync (needed for v4 model)
az rest --method post --url "https://management.azure.com/subscriptions/<subscription_id>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app>/syncfunctiontriggers?api-version=2023-12-01"
```

### .NET 8 isolated

```powershell
cd src\dotnet
func azure functionapp publish <function_app_name> --dotnet-isolated
```

> The `dotnet` SDK builds the project locally (targeting `net8.0`) before upload. The .NET 10 SDK can build `net8.0` targets.

### Java (requires Maven + JDK 17)

> **Toolchain note:** Maven (`mvn`) and JDK 17 must be installed locally. If unavailable, the infra can still be provisioned and verified — function registration requires the build step.

```powershell
cd src\java
# Set env vars from terraform output
$env:FUNC_APP_NAME = "<function_app_name>"
$env:FUNC_RG_NAME  = "<resource_group_name>"
mvn clean package
func azure functionapp publish $env:FUNC_APP_NAME --java
```

### PowerShell

```powershell
cd src\powershell
func azure functionapp publish <function_app_name> --powershell
```

## Verify deployment

Because Easy Auth is enabled (`requireAuthentication = true`), unauthenticated requests return 302 (browser) or 401 (API clients). This is **expected and correct** — it confirms Easy Auth is enforced.

```powershell
# Confirm function is registered
az functionapp function list -g <rg> -n <app> -o table

# Confirm Easy Auth is enforced (expect 401)
curl -s -o nul -w "%{http_code}" https://<app>.azurewebsites.net/api/hello

# Browser test: navigate to https://<app>.azurewebsites.net/api/hello
# → redirected to Entra login → returns {"message":"hello-world"} after sign-in
```

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | Name of the deployed RG |
| `function_app_name` | Name of the Function App |
| `function_app_url` | Default HTTPS URL |
| `app_registration_client_id` | Entra App Registration client ID |
| `runtime` | Runtime that was deployed |
| `linux_fx_version` | Resolved `linuxFxVersion` string |

## Design notes

- **Runtime mapping lives in the module** (`modules/function-app/main.tf` `locals.runtime_defaults`). Adding a new runtime requires only a new entry in the map.
- **`azapi_update_resource` for singleton children** — `appsettings` and `authsettingsV2` are ARM singleton config children that return 405 on DELETE. Using `azapi_update_resource` (GET + merge + PUT) avoids this; `azapi_resource` would fail on destroy/replace.
- **Random suffix per module invocation** — `random_string.suffix` is inside the module so each apply gets a fresh suffix. Avoids name collisions between sequential runtime deployments sharing one state file.
- **No circular dependency** — `func_name` is computed in `locals` from the random suffix, so the Entra redirect URI can reference it before the Function App resource is created.
