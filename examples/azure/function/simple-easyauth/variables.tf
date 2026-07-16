variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "3cbb82c6-dcc1-4a5f-8c1f-0e1c70fc2f34"
}

variable "tenant_id" {
  type        = string
  description = "Entra ID tenant ID — used for the OIDC issuer URL"
  default     = "e79f2d5f-f212-4f53-8381-68e32b902d32"
}

variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "centralus"
}

variable "environment" {
  type        = string
  description = "Short environment label (dev / test / prod)"
  default     = "dev"
}
