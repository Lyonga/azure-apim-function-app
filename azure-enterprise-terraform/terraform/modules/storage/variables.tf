variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "containers" {
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}
