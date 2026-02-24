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
  description = "Map of subnets. Example: { app = { address_prefixes=[\"10.10.1.0/24\"], nsg_rules=[...] } }"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
        actions = list(string)
      })
    })), [])
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
