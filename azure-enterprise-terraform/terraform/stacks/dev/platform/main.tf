data "azurerm_client_config" "current" {}

# Optionally create a subscription (enterprise-specific). Disabled by default.
module "subscription" {
  source                    = "../../../modules/subscription"
  enable                    = var.enable_subscription_creation
  subscription_display_name = var.new_subscription_display_name
  billing_scope_id          = var.billing_scope_id
  workload                  = "DevTest"
}

# Optionally pin provider to a subscription (common in enterprise with per-env subscriptions).
# If you set var.subscription_id, ensure your auth context has access.
provider "azurerm" {
  alias           = "sub"
  subscription_id = var.subscription_id
  features {}
}

# Resource group (created or existing)
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

# Observability baseline
module "log_analytics" {
  source              = "../../../modules/observability"
  workspace_name      = "log-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = var.location
  sku                 = "Standard"
  retention_in_days   = 30
  tags                = local.common_tags
}

# Network baseline
module "network" {
  source              = "../../../modules/network"
  name                = "vnet-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = var.location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

# Key Vault
module "keyvault" {
  source                      = "../../../modules/keyvault"
  name                        = var.keyvault_name
  resource_group_name         = local.rg_name
  location                    = var.location
  tenant_id                   = var.tenant_id
  enable_rbac_authorization   = "RBAC"
  soft_delete_retention_days  = 30
  sku_name                    = "Standard"
  purge_protection_enabled    = true
  tags                = local.common_tags
}

# Storage Account + containers
module "storage" {
  source                      = "../../../modules/storage"
  name                        = var.storage_account_name
  resource_group_name         = local.rg_name
  location                    = var.location
  allow_blob_public_access    = "Disabled"
  account_kind                = "Standard"
  account_replication_type    = "LRS"
  min_tls_version             = "1.2"
  account_tier                = "Standard"
  containers = {
    appdata = { access_type = "private" }
    logs    = { access_type = "private" }
  }
  tags = local.common_tags
}

# Container Registry
module "acr" {
  source              = "../../../modules/container_registry"
  name                = var.acr_name
  resource_group_name = local.rg_name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = "Standard"
  tags                = local.common_tags
}

# AKS
# module "aks" {
#   source                     = "../../../modules/aks"
#   name                       = "aks-${var.environment}-${var.project_name}"
#   resource_group_name        = local.rg_name
#   location                   = var.location
#   dns_prefix                 = "aks-${var.environment}-${var.project_name}"
#   subnet_id                  = module.network.subnet_ids["aks"]
#   node_pool                  = var.aks_node_pool
#   log_analytics_workspace_id = module.log_analytics.workspace_id
#   tags                       = local.common_tags
# }

# Example: assign a common built-in policy (audit VMs without managed disks, etc).
# Swap in your org-approved policy IDs.
module "policy_audit_vms" {
  source               = "../../../modules/policy_assignment"
  name                 = "audit-vm-manageddisks"
  display_name         = "Audit VMs without managed disks"
  parameters           = "<REQUIRED_VALUE>"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  tags                 = "<REQUIRED_VALUE>"
}

# Optional Azure DevOps repo + branch policy (OFF by default)
module "ado_repo" {
  source                     = "../../../modules/azuredevops_repo"
  enable                     = var.enable_azuredevops_repo
  project_name               = var.azuredevops_project
  default_branch             = "<REQUIRED_VALUE>"
  repo_name                  = var.azuredevops_repo_name
  enable_min_reviewers_policy = true
  min_reviewer_count          = 1
}
