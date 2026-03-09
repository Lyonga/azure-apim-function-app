locals {
  default_subnets = {
    AzureFirewallSubnet = {
      address_prefixes = [var.firewall_subnet_cidr]
      nsg_rules        = []
    }
    AzureBastionSubnet = {
      address_prefixes = [var.bastion_subnet_cidr]
      nsg_rules        = []
    }
    shared-services = {
      address_prefixes = [var.shared_services_subnet_cidr]
      nsg_rules        = var.shared_services_nsg_rules
    }
    private-endpoints = {
      address_prefixes                          = [var.private_endpoints_subnet_cidr]
      private_endpoint_network_policies_enabled = false
      nsg_rules                                 = []
    }
    dns-inbound = {
      address_prefixes = [var.dns_inbound_subnet_cidr]
      nsg_rules        = []
    }
    dns-outbound = {
      address_prefixes = [var.dns_outbound_subnet_cidr]
      nsg_rules        = []
    }
  }
}

module "network" {
  source                  = "../network"
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  address_space           = var.address_space
  dns_servers             = var.dns_servers
  ddos_protection_plan_id = var.ddos_protection_plan_id
  subnets                 = var.subnets == null ? local.default_subnets : var.subnets
  tags                    = var.tags
}

resource "azurerm_public_ip" "firewall" {
  count               = var.enable_firewall ? 1 : 0
  name                = "${var.name}-fw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  count               = var.enable_firewall ? 1 : 0
  name                = "${var.name}-fw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.network.subnet_ids["AzureFirewallSubnet"]
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
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

output "firewall_private_ip" {
  value = var.enable_firewall ? azurerm_firewall.this[0].ip_configuration[0].private_ip_address : null
}
