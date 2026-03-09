variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "version" {
  type    = string
  default = "16"
}

variable "delegated_subnet_id" {
  type    = string
  default = null
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "administrator_login" {
  type    = string
  default = null
}

variable "administrator_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "zone" {
  type    = string
  default = null
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "sku_name" {
  type    = string
  default = "GP_Standard_D2s_v3"
}

variable "backup_retention_days" {
  type    = number
  default = 14
}

variable "geo_redundant_backup_enabled" {
  type    = bool
  default = true
}

variable "authentication" {
  type = object({
    active_directory_auth_enabled = bool
    password_auth_enabled         = bool
    tenant_id                     = optional(string)
  })
  default = {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "databases" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
