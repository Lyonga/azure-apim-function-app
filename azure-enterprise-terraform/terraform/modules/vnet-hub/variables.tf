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

variable "ddos_protection_plan_id" {
  type    = string
  default = null
}

variable "enable_firewall" {
  type    = bool
  default = false
}

variable "firewall_sku_tier" {
  type    = string
  default = "Standard"
}

variable "firewall_subnet_cidr" {
  type    = string
  default = "10.0.0.0/26"
}

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.0.64/26"
}

variable "shared_services_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_endpoints_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "dns_inbound_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "dns_outbound_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "shared_services_nsg_rules" {
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
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    enforce_private_link_service_network_policies = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table_id                                = optional(string)
    nat_gateway_id                                = optional(string)
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
