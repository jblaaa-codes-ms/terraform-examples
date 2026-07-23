variable "environment" {
  type        = string
  description = "Short environment label (dev / test / prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "centralus"
}

variable "tenant_id" {
  type        = string
  description = "Entra ID tenant ID — used for the OIDC issuer URL"
}

variable "runtime" {
  type        = string
  description = "Function App runtime: node, java, dotnet, python, or powershell"

  validation {
    condition     = contains(["node", "java", "dotnet", "python", "powershell"], var.runtime)
    error_message = "runtime must be one of: node, java, dotnet, python, powershell"
  }
}

variable "runtime_version" {
  type        = string
  description = "Optional version override for the selected runtime (e.g. '3.12' for python). Overrides the default linuxFxVersion for that runtime."
  default     = null
}
