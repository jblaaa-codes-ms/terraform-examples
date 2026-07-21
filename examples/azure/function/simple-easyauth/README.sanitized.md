# simple-easyauth — Python source

HTTP trigger function using the **Python v2 programming model**. Returns `{"message": "hello-world"}` at `GET /api/hello`.

> Easy Auth (Entra ID) is enforced at the App Service platform layer — the function itself uses `AuthLevel.ANONYMOUS` because the platform already handles authentication.

## Local settings

Copy the example to a real `local.settings.json` before running the function locally:

```bash
cp local.settings.json.example local.settings.json   # Bash / macOS / Linux
# copy local.settings.json.example local.settings.json  # Windows cmd
```

**`local.settings.json` template** (`local.settings.json.example`):

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python"
  }
}
```

`AzureWebJobsStorage: "UseDevelopmentStorage=true"` tells the local host to use the [Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite) storage emulator. Alternatively, replace the value with a real Azure Storage connection string.

> **Never commit `local.settings.json`** — it can contain connection strings and secrets. It is already excluded by `.funcignore` (and should be added to `.gitignore` for your project). `local.settings.json.example` is the safe, committed stand-in.

## Local development

```bash
# 1. Create and activate a virtual environment
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # Linux/macOS

# 2. Install dependencies
pip install -r requirements.txt

# 3. Start the local function host
func start
# → http://localhost:7071/api/hello
```

## Deploy to Azure

> **Resource names** used below come from `terraform output` in the parent stack (`terraform/simple-easyauth/`).  
> RG: `<resource-group>` · App: `<function-app-name>`

### Option A: Azure Functions Core Tools

```bash
func azure functionapp publish <function-app-name> --python
```

The publish command performs a remote Oryx build, packages the result as a squashfs artifact, uploads it to blob storage, and sets `WEBSITE_RUN_FROM_PACKAGE` to the blob URL automatically.

---

### Option B: az CLI zip deploy (no Core Tools required)

Use this when Azure Functions Core Tools is not available.

**Step 1 — Enable remote build**

Tell the SCM endpoint to run Oryx so `requirements.txt` dependencies are installed on the server:

```bash
az functionapp config appsettings set \
  -g <resource-group> \
  -n <function-app-name> \
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

> `.venv/`, `__pycache__/`, and `local.settings.json` are intentionally excluded — they are dev-only and listed in `.funcignore`.

**Step 3 — Deploy**

```bash
az functionapp deployment source config-zip \
  -g <resource-group> \
  -n <function-app-name> \
  --src deploy.zip
```

`config-zip` posts the zip to the Kudu SCM endpoint. The Linux Consumption plan manages `WEBSITE_RUN_FROM_PACKAGE` internally after a successful zip deploy. **Do not** manually set `WEBSITE_RUN_FROM_PACKAGE=1` with an empty or missing package — that prevents the function host from starting (known gotcha on Linux Consumption).

**Step 4 — Clean up and verify**

```bash
# Remove the local zip
Remove-Item deploy.zip          # PowerShell
# rm deploy.zip                 # Bash

# Confirm the function is registered
az functionapp function list \
  -g <resource-group> \
  -n <function-app-name> \
  -o table
```

> **Easy Auth note:** because `requireAuthentication = true`, an unauthenticated `curl` to `/api/hello` returns `302` (browser clients) or `401` (API clients) — that is expected and correct. Use `az functionapp function list` to confirm registration; do not disable Easy Auth for testing.

## Testing the deployed function (with Easy Auth)

Easy Auth intercepts every request before it reaches the function, so all calls to `/api/hello` require a valid Entra identity. Two ways to test:

### Browser flow (easiest — great for customer demos)

Navigate to:

```
https://<function-app-name>.azurewebsites.net/api/hello
```

You will be redirected through the Entra login page and, once authenticated, land directly on the JSON response:

```json
{"message": "hello-world"}
```

HTTP 200. No token wrangling required — the browser handles the OIDC redirect automatically.

### ****** via curl (programmatic)

Acquire a token scoped to the app registration's audience, then pass it as a `Bearer` header.

```bash
# Get the app registration client ID from Terraform output
APP_REG_CLIENT_ID=$(terraform -chdir=.. output -raw app_registration_client_id)

# Acquire a token for the Easy Auth audience
TOKEN=$(az account get-access-token \
  --resource "api://${APP_REG_CLIENT_ID}" \
  --query accessToken -o tsv)

# Call the function with the ******
curl -H "Authorization: ******" \
  https://<function-app-name>.azurewebsites.net/api/hello
```

Expected response:

```json
{"message": "hello-world"}
```

HTTP 200.

> **Caveat:** `az account get-access-token --resource api://<clientId>` requires the calling account to have consented to the app registration and the app reg to expose that audience. In some tenant configurations this command will fail with an AADSTS error. If that happens, the **browser flow above is the reliable demo path** — it uses the standard OIDC authorization-code flow which is always wired correctly by Easy Auth.
