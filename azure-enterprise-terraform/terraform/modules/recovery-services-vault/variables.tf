variable "name" {
  type        = string
  description = "Recovery Services Vault name."
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
  description = "Vault SKU."
  default     = "Standard"
}

variable "storage_mode_type" {
  type        = string
  description = "Storage mode."
  default     = "GeoRedundant"
}

variable "cross_region_restore_enabled" {
  type        = bool
  description = "Enable CRR when GeoRedundant."
  default     = false
}

variable "soft_delete_enabled" {
  type        = bool
  description = "Enable soft delete."
  default     = true
}

variable "identity_type" {
  type        = string
  description = "Managed identity type."
  default     = null
}

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned identity ids."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
