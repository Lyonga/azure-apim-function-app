variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "dns_servers" {
  type    = list(string)
  default = null
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "integration_subnet_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "data_subnet_cidr" {
  type    = string
  default = "10.10.3.0/24"
}

variable "private_endpoints_subnet_cidr" {
  type    = string
  default = "10.10.10.0/24"
}

variable "app_subnet_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = optional(string, "*")
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  }))
  default = []
}

variable "integration_subnet_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = optional(string, "*")
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  }))
  default = []
}

variable "data_subnet_nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = optional(string, "*")
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  }))
  default = []
}

variable "subnets" {
  type    = any
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
