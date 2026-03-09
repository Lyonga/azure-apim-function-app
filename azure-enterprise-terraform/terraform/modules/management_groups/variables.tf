variable "root_management_group_id" {
  type = string
}

variable "prefix" {
  type    = string
  default = "alz"
}

variable "display_name_prefix" {
  type    = string
  default = "ALZ"
}

variable "subscriptions_by_group" {
  type    = map(list(string))
  default = {}
}
