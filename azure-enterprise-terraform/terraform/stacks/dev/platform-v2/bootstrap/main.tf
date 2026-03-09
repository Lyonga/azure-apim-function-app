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

module "state_storage" {
  source                        = "../../../../modules/state-storage"
  create_resource_group         = var.create_resource_group
  resource_group_name           = var.resource_group_name
  location                      = var.location
  storage_account_name          = var.storage_account_name
  containers                    = var.containers
  account_replication_type      = var.account_replication_type
  public_network_access_enabled = var.public_network_access_enabled
  shared_access_key_enabled     = var.shared_access_key_enabled
  enable_network_rules          = var.enable_network_rules
  ip_rules                      = var.ip_rules
  virtual_network_subnet_ids    = var.virtual_network_subnet_ids
  tags                          = module.tags.tags
}
