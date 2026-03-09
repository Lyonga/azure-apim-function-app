locals {
  default_subnets = {
    app = {
      address_prefixes = [var.app_subnet_cidr]
      nsg_rules        = var.app_subnet_nsg_rules
    }
    integration = {
      address_prefixes = [var.integration_subnet_cidr]
      nsg_rules        = var.integration_subnet_nsg_rules
    }
    data = {
      address_prefixes = [var.data_subnet_cidr]
      nsg_rules        = var.data_subnet_nsg_rules
    }
    private-endpoints = {
      address_prefixes                          = [var.private_endpoints_subnet_cidr]
      private_endpoint_network_policies_enabled = false
      nsg_rules                                 = []
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
  subnets             = var.subnets == null ? local.default_subnets : var.subnets
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
