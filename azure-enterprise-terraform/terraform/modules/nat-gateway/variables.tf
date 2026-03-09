variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "create_public_ip" {
  type    = bool
  default = true
}

variable "idle_timeout_in_minutes" {
  type    = number
  default = 10
}

variable "zones" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
