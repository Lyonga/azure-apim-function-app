terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.115" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
    time    = { source = "hashicorp/time", version = "~> 0.12" }
  }
}

provider "azurerm" { features {} }

data "azurerm_client_config" "current" {}

# Import outputs from platform stacks by variables (simpler than remote_state for this starter)
# In a mature setup, use terraform_remote_state or a pipeline artifact.
locals {
  tags = merge(var.tags, {
    environment = var.environment
    service     = var.service_name
  })
}

module "naming" {
  source         = "../../modules/naming"
  prefix         = var.prefix
  environment    = var.environment
  service        = var.service_name
  location_short = var.location_short
}

module "rg" {
  source   = "../../modules/resource-group"
  name     = module.naming.rg_name
  location = var.location
  tags     = local.tags
}

module "spoke" {
  source              = "../../modules/vnet-spoke"
  name                = module.naming.vnet_spoke_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = var.spoke_address_space
  tags                = local.tags

  subnet_workload_cidr          = var.spoke_workload_subnet_cidr
  subnet_private_endpoints_cidr = var.spoke_pe_subnet_cidr
}

module "peering" {
  source        = "../../modules/vnet-peering"
  hub_vnet_id   = var.hub_vnet_id
  hub_vnet_name = var.hub_vnet_name
  hub_rg_name   = var.hub_rg_name

  spoke_vnet_id   = module.spoke.vnet_id
  spoke_vnet_name = module.spoke.vnet_name
  spoke_rg_name   = module.rg.name
}

# Create private DNS zones in the workload RG (simple baseline).
# Enterprise: create zones in hub/management subscription and link spokes via separate stacks.
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.rg.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.rg.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "link-kv-${var.environment}"
  resource_group_name   = module.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = module.spoke.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  name                  = "link-blob-${var.environment}"
  resource_group_name   = module.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.spoke.vnet_id
}

module "storage" {
  source              = "../../modules/storage"
  name                = module.naming.sa_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = local.tags
  replication         = var.storage_replication
  public_network_access_enabled = false
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = module.naming.kv_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
  public_network_access_enabled = false
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
}

# Private Endpoints
module "pe_kv" {
  source              = "../../modules/private-endpoint"
  name                = "pe-kv-${module.naming.kv_name}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  subnet_id           = module.spoke.private_endpoints_subnet_id
  target_resource_id  = module.keyvault.id
  subresource_names   = ["vault"]
  private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  tags                = local.tags
}

module "pe_blob" {
  source              = "../../modules/private-endpoint"
  name                = "pe-sa-${module.naming.sa_name}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  subnet_id           = module.spoke.private_endpoints_subnet_id
  target_resource_id  = module.storage.id
  subresource_names   = ["blob"]
  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  tags                = local.tags
}

# Diagnostics (requires LAW from platform-management)
module "diag_kv" {
  source                     = "../../modules/diagnostics"
  name                       = "diag-kv"
  target_resource_id         = module.keyvault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_logs               = ["AuditEvent"]
}

# Storage diagnostics categories vary; we keep metrics only for baseline
module "diag_sa" {
  source                     = "../../modules/diagnostics"
  name                       = "diag-sa"
  target_resource_id         = module.storage.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_metrics            = ["AllMetrics"]
}

output "workload_rg" { value = module.rg.name }
output "spoke_vnet_id" { value = module.spoke.vnet_id }
output "storage_account_name" { value = module.storage.name }
output "key_vault_name" { value = module.keyvault.name }
