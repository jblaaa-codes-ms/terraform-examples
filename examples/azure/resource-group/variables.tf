variable "location" {
  description = "Azure region where the resource group will be created."
  type        = string
  default     = "East US"
}

variable "name" {
  description = "Name of the resource group."
  type        = string
  default     = "example-rg"
}

variable "tags" {
  description = "Tags to apply to the resource group."
  type        = map(string)
  default     = {}
}
