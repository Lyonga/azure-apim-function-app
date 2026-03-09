variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "backend_ip_addresses" {
  type    = list(string)
  default = []
}

variable "backend_fqdns" {
  type    = list(string)
  default = []
}

variable "frontend_private_ip_address" {
  type    = string
  default = null
}

variable "frontend_port" {
  type    = number
  default = 443
}

variable "backend_port" {
  type    = number
  default = 443
}

variable "backend_protocol" {
  type    = string
  default = "Https"
}

variable "listener_protocol" {
  type    = string
  default = "Https"
}

variable "request_timeout" {
  type    = number
  default = 30
}

variable "priority" {
  type    = number
  default = 100
}

variable "sku_name" {
  type    = string
  default = "WAF_v2"
}

variable "sku_tier" {
  type    = string
  default = "WAF_v2"
}

variable "capacity" {
  type    = number
  default = 2
}

variable "firewall_policy_id" {
  type    = string
  default = null
}

variable "ssl_policy_type" {
  type    = string
  default = "Predefined"
}

variable "ssl_policy_name" {
  type    = string
  default = "AppGwSslPolicy20220101S"
}

variable "enable_waf_configuration" {
  type    = bool
  default = true
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "waf_rule_set_version" {
  type    = string
  default = "3.2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
