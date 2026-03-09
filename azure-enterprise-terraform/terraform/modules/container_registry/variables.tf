variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Premium"
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "anonymous_pull_enabled" {
  type    = bool
  default = false
}

variable "data_endpoint_enabled" {
  type    = bool
  default = true
}

variable "network_rule_bypass_option" {
  type    = string
  default = "None"
}

variable "quarantine_policy_enabled" {
  type    = bool
  default = true
}

variable "zone_redundancy_enabled" {
  type    = bool
  default = true
}

variable "export_policy_enabled" {
  type    = bool
  default = false
}

variable "retention_policy_enabled" {
  type    = bool
  default = true
}

variable "retention_policy_days" {
  type    = number
  default = 30
}

variable "trust_policy_enabled" {
  type    = bool
  default = true
}

variable "georeplication_locations" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
