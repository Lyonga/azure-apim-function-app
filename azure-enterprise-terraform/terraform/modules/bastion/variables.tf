variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "copy_paste_enabled" {
  type    = bool
  default = true
}

variable "file_copy_enabled" {
  type    = bool
  default = false
}

variable "ip_connect_enabled" {
  type    = bool
  default = false
}

variable "shareable_link_enabled" {
  type    = bool
  default = false
}

variable "tunneling_enabled" {
  type    = bool
  default = true
}

variable "scale_units" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
