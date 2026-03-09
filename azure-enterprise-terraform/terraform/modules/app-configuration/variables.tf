variable "name" {
  type        = string
  description = "App Configuration name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Location."
}

variable "sku" {
  type        = string
  description = "SKU."
  default     = "standard"
}

variable "local_auth_enabled" {
  type        = bool
  description = "Allow local auth keys."
  default     = false
}

variable "public_network_access" {
  type        = string
  description = "Public network access mode."
  default     = "Disabled"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection."
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention days."
  default     = 7
}

variable "identity_type" {
  type        = string
  description = "Managed identity type."
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned identity ids."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
