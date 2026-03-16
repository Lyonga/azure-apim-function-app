locals {
  default_subnets = {
    app = {
      address_prefixes                              = [var.app_subnet_cidr]
      service_endpoints                             = []
      private_endpoint_network_policies             = null
      private_endpoint_network_policies_enabled     = true
      enforce_private_link_service_network_policies = true
      private_link_service_network_policies_enabled = true
      route_table_id                                = null
      nat_gateway_id                                = null
      nsg_rules                                     = var.app_subnet_nsg_rules
      delegations                                   = []
    }
    integration = {
      address_prefixes                              = [var.integration_subnet_cidr]
      service_endpoints                             = []
      private_endpoint_network_policies             = null
      private_endpoint_network_policies_enabled     = true
      enforce_private_link_service_network_policies = true
      private_link_service_network_policies_enabled = true
      route_table_id                                = null
      nat_gateway_id                                = null
      nsg_rules                                     = var.integration_subnet_nsg_rules
      delegations                                   = []
    }
    data = {
      address_prefixes                              = [var.data_subnet_cidr]
      service_endpoints                             = []
      private_endpoint_network_policies             = null
      private_endpoint_network_policies_enabled     = true
      enforce_private_link_service_network_policies = true
      private_link_service_network_policies_enabled = true
      route_table_id                                = null
      nat_gateway_id                                = null
      nsg_rules                                     = var.data_subnet_nsg_rules
      delegations                                   = []
    }
    private-endpoints = {
      address_prefixes                              = [var.private_endpoints_subnet_cidr]
      service_endpoints                             = []
      private_endpoint_network_policies             = "Disabled"
      private_endpoint_network_policies_enabled     = false
      enforce_private_link_service_network_policies = true
      private_link_service_network_policies_enabled = true
      route_table_id                                = null
      nat_gateway_id                                = null
      nsg_rules                                     = []
      delegations                                   = []
    }
  }
}

module "network" {
  source              = "../network"
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  subnets             = length(var.subnets) == 0 ? local.default_subnets : var.subnets
  tags                = var.tags
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "subnet_ids" {
  value = module.network.subnet_ids
}
