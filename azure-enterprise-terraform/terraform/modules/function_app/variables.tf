variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "app_service_plan_sku" {
  type    = string
  default = "EP1"
}

variable "runtime" {
  type    = string
  default = "python"
}

variable "runtime_version" {
  type    = string
  default = "3.11"
}

variable "functions_extension_version" {
  type    = string
  default = "~4"
}

variable "application_insights_connection_string" {
  type      = string
  sensitive = true
  default   = null
}

variable "https_only" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "virtual_network_subnet_id" {
  type    = string
  default = null
}

variable "identity_type" {
  type    = string
  default = "SystemAssigned"

  validation {
    condition = contains([
      "None",
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "identity_type must be None, SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  type    = list(string)
  default = []
}

variable "ftps_state" {
  type    = string
  default = "Disabled"
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "scm_minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "always_on" {
  type    = bool
  default = false
}

variable "vnet_route_all_enabled" {
  type    = bool
  default = true
}

variable "health_check_path" {
  type    = string
  default = null
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
