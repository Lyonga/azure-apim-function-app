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

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)

    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string   # Inbound/Outbound
      access                     = string   # Allow/Deny
      protocol                   = string   # Tcp/Udp/*

      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), [])
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
