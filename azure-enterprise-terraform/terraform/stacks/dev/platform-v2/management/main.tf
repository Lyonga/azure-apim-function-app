module "tags" {
  source              = "../../../../modules/platform-tags"
  environment         = var.environment
  application         = var.application
  created_by          = var.created_by
  business_owner      = var.business_owner
  source_repo         = var.source_repo
  terraform_workspace = var.terraform_workspace
  recovery_tier       = var.recovery_tier
  cost_center         = var.cost_center
  compliance_boundary = var.compliance_boundary
  creation_date_utc   = var.creation_date_utc
  last_modified_utc   = var.last_modified_utc
  additional_tags     = var.additional_tags
}

module "resource_group" {
  source   = "../../../../modules/resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = module.tags.tags
}

module "workspace" {
  source              = "../../../../modules/log-analytics"
  name                = var.workspace_name
  resource_group_name = module.resource_group.name
  location            = var.location
  retention_in_days   = var.workspace_retention_in_days
  tags                = module.tags.tags
}

module "diagnostics_archive" {
  source                        = "../../../../modules/storage"
  name                          = var.diagnostics_storage_account_name
  resource_group_name           = module.resource_group.name
  location                      = var.location
  public_network_access_enabled = true
  shared_access_key_enabled     = false
  enable_network_rules          = true
  network_bypass                = ["AzureServices"]
  tags                          = module.tags.tags
}

module "action_group" {
  source              = "../../../../modules/action-group"
  name                = var.action_group_name
  resource_group_name = module.resource_group.name
  short_name          = var.action_group_short_name
  email_receivers     = var.action_group_email_receivers
  tags                = module.tags.tags
}

module "recovery_services_vault" {
  source              = "../../../../modules/recovery-services-vault"
  name                = var.recovery_services_vault_name
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = module.tags.tags
}

module "monitoring_baseline" {
  source                     = "../../../../modules/monitoring-baseline"
  name                       = "subscription-activity-logs"
  subscription_id            = var.subscription_id
  log_analytics_workspace_id = module.workspace.workspace_id
  storage_account_id         = module.diagnostics_archive.account_id
}
