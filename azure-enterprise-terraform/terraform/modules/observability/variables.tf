variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sku" {
  description = "The SKU for the Log Analytics workspace."
  type        = string
  default     = "Standard"
}
