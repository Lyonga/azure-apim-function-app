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
  default = "Y1"
}

variable "runtime" {
  type    = string
  default = "python"
}

variable "runtime_version" {
  type    = string
  default = "3.11"
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
