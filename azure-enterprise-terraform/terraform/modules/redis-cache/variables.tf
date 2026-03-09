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
  default = "Premium"
}

variable "family" {
  type    = string
  default = "P"
}

variable "capacity" {
  type    = number
  default = 1
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "replicas_per_primary" {
  type    = number
  default = 1
}

variable "maxmemory_reserved" {
  type    = number
  default = 50
}

variable "maxfragmentationmemory_reserved" {
  type    = number
  default = 50
}

variable "maxmemory_delta" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
