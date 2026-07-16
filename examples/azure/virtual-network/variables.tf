variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "example-rg"
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "example-vnet"
}

variable "address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the default subnet."
  type        = string
  default     = "default"
}

variable "subnet_prefix" {
  description = "Address prefix for the default subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
