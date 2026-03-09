variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "Developer_1"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "virtual_network_type" {
  type    = string
  default = "None"
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "identity_type" {
  type    = string
  default = "SystemAssigned"
}

variable "identity_ids" {
  type    = list(string)
  default = []
}

variable "api_name" {
  type    = string
  default = null
}

variable "api_display_name" {
  type    = string
  default = null
}

variable "api_path" {
  type    = string
  default = null
}

variable "api_revision" {
  type    = string
  default = "1"
}

variable "api_spec_path" {
  type    = string
  default = null
}

variable "backend_url" {
  type    = string
  default = null

  validation {
    condition     = var.backend_url == null || startswith(lower(var.backend_url), "https://")
    error_message = "backend_url must use https."
  }
}

variable "named_value_name" {
  type    = string
  default = "func-host-key"
}

variable "function_app_name" {
  type    = string
  default = null
}

variable "function_resource_group" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
