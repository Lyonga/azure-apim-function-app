data "azurerm_client_config" "current" {}

# Optionally create a subscription (enterprise-specific). Disabled by default.
# module "subscription" {
#   source                    = "../../../modules/subscription"
#   enable                    = var.enable_subscription_creation
#   subscription_display_name = var.new_subscription_display_name
#   billing_scope_id          = var.billing_scope_id
#   workload                  = "DevTest"
# }

# If you set var.subscription_id, ensure your auth context has access.
provider "azurerm" {
  alias           = "sub"
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

# Resource group (created or existing)
module "rg" {
  source   = "../../../modules/resource_group"
  count    = var.create_resource_group ? 1 : 0
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}


# Observability baseline
module "log_analytics" {
  source              = "../../../modules/observability"
  name                = local.analytics_name
  resource_group_name = local.project_rg_name
  location            = var.location
  sku                 = var.analytics_sku
  retention_in_days   = var.retention_in_days
  tags                = local.common_tags
}

# Network baseline
module "network" {
  source              = "../../../modules/network"
  name                = local.Vnet_name
  resource_group_name = local.project_rg_name
  location            = var.location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

# Key Vault
module "keyvault" {
  source                      = "../../../modules/keyvault"
  name                        = local.kv_name
  resource_group_name         = local.project_rg_name
  location                    = var.location
  tenant_id                   = var.tenant_id

  enable_rbac_authorization   = true
  soft_delete_retention_days  = 30
  sku_name                    = var.kv_sku
  purge_protection_enabled    = true
  tags                = local.common_tags
}

# Storage Account + containers to test
module "storage" {
  source                      = "../../../modules/storage"
  name                        = local.sa_name
  resource_group_name         = local.project_rg_name
  location                    = var.location
  allow_blob_public_access    = var.allow_blob_public_access

  account_kind                = var.storage_account_kind
  account_replication_type    = var.storage_account_replication_type
  min_tls_version             = var.storage_account_min_tls_version
  account_tier                = var.storage_account_tier
  containers                  = var.storage_account_containers
  tags                        = local.common_tags
}

# Container Registry
module "acr" {
  source              = "../../../modules/container_registry"
  name                = local.acr_name
  resource_group_name = local.rg_name
  location            = var.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = local.common_tags
}

module "policy_audit_vms" {
  source               = "../../../modules/policy_assignment"
  name                 = local.plocy_audit_vms_name
  display_name         = "Audit VMs without managed disks"
  parameters           = var.policy_parameters
  policy_definition_id = var.policy_definition_id
  scope               = module.rg[0].id
  tags                 = local.common_tags
}

# module "ado_repo" {
#   source                     = "../../../modules/azuredevops_repo"
#   enable                     = var.enable_azuredevops_repo
#   project_name               = var.azuredevops_project
#   branch_name            = var.azuredevops_default_branch
#   repository_name                 = var.azuredevops_repo_name
#   enable_min_reviewers_policy = var.enable_min_reviewers_policy
#   min_reviewer_count          = var.min_reviewer_count
# }

