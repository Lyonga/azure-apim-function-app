variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {
  type    = string
  //default = "Standard"
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tenant_id" { type = string }

variable "enable_rbac_authorization" { 
  type = bool 
  default = true 
  }

variable "soft_delete_retention_days" { 
  type = number 
  default = 90 
  }
