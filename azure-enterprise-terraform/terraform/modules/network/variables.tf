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

variable "subnets" {
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string)
    # Keep the legacy boolean input until callers are fully migrated.
    private_endpoint_network_policies_enabled     = optional(bool, true)
    enforce_private_link_service_network_policies = optional(bool, true)
    # Keep the legacy boolean input until callers are fully migrated.
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
}

variable "tags" {
  type    = map(string)
  default = {}
}
