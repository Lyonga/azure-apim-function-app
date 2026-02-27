variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tenant_id" { type = string }
variable "tags" { type = map(string) }

variable "public_network_access_enabled" { type = bool, default = false }
variable "purge_protection_enabled" { type = bool, default = true }
variable "enable_rbac_authorization" { type = bool, default = true }
