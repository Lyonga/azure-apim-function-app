variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "enable_rbac_authorization" {
  type    = bool
  default = true
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "network_acls_bypass" {
  type    = string
  default = "None"
}

variable "network_acls_default_action" {
  type    = string
  default = "Deny"
}

variable "network_acls_ip_rules" {
  type    = list(string)
  default = []
}

variable "network_acls_virtual_network_subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
