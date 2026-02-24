variable "name" {
  type = string
}

variable "display_name" {
  type = string
}

variable "policy_definition_id" {
  type = string
}

variable "scope" {
  type = string
}

variable "parameters" {
  type    = any
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
