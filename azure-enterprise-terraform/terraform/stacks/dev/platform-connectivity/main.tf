terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.115" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "azurerm" { features {} }

module "naming" {
  source         = "../../modules/naming"
  prefix         = var.prefix
  environment    = var.environment
  service        = "net"
  location_short = var.location_short
}

locals {
  tags = merge(var.tags, {
    environment = var.environment
    service     = "platform-connectivity"
  })
}

module "rg" {
  source   = "../../modules/resource-group"
  name     = module.naming.rg_name
  location = var.location
  tags     = local.tags
}

module "hub" {
  source              = "../../modules/vnet-hub"
  name                = module.naming.vnet_hub_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = var.hub_address_space
  tags                = local.tags
  enable_firewall     = var.enable_firewall
  firewall_subnet_cidr = var.firewall_subnet_cidr
}

output "hub_vnet_id" { value = module.hub.vnet_id }
output "hub_vnet_name" { value = module.hub.vnet_name }
output "hub_rg_name" { value = module.rg.name }
output "hub_private_endpoints_subnet_id" { value = module.hub.private_endpoints_subnet_id }
output "hub_firewall_private_ip" { value = module.hub.firewall_private_ip }
