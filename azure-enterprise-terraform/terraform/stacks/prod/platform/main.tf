data "azurerm_client_config" "current" {}

module "rg" {
  source   = "../../../modules/resource_group"
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

locals {
  rg_name = var.create_resource_group ? module.rg[0].name : var.resource_group_name
}

module "log_analytics" {
  source              = "../../../modules/observability"
  workspace_name      = "log-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = var.location
  retention_in_days   = 90
  tags                = local.common_tags
}

module "network" {
  source              = "../../../modules/network"
  name                = "vnet-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = var.location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

module "keyvault" {
  source                      = "../../../modules/keyvault"
  name                        = var.keyvault_name
  resource_group_name         = local.rg_name
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true  # Added missing attribute
  purge_protection_enabled    = true  # Added missing attribute
  soft_delete_retention_days  = 30    # Added missing attribute
  tags                        = local.common_tags
}

module "storage" {
  source                      = "../../../modules/storage"
  name                        = var.storage_account_name
  resource_group_name         = local.rg_name
  location                    = var.location
  allow_blob_public_access    = false  # Added missing attribute
  account_kind                = "StorageV2"  # Added missing attribute
  account_replication_type    = "LRS"  # Added missing attribute
  min_tls_version             = "1.2"  # Added missing attribute
  containers = {
    appdata = { access_type = "private" }
    logs    = { access_type = "private" }
  }
  tags = local.common_tags
}

module "acr" {
  source              = "../../../modules/container_registry"
  name                = var.acr_name
  resource_group_name = local.rg_name
  location            = var.location
  admin_enabled       = false
  tags                = local.common_tags
}

module "aks" {
  source                     = "../../../modules/aks"
  name                       = "aks-${var.environment}-${var.project_name}"
  resource_group_name        = local.rg_name
  location                   = var.location
  dns_prefix                 = "aks-${var.environment}-${var.project_name}"
  subnet_id                  = module.network.subnet_ids["aks"]
  node_pool                  = var.aks_node_pool
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags                       = local.common_tags
}
