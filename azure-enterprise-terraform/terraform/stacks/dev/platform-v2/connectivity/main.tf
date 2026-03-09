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

module "hub_network" {
  source              = "../../../../modules/vnet-hub"
  name                = var.hub_vnet_name
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = var.hub_address_space
  dns_servers         = var.dns_servers
  enable_firewall     = var.enable_firewall
  tags                = module.tags.tags
}

module "private_dns" {
  source              = "../../../../modules/private-dns"
  resource_group_name = module.resource_group.name
  location            = var.location
  zones               = var.private_dns_zones
  vnet_ids_to_link = {
    hub = module.hub_network.vnet_id
  }
  tags = module.tags.tags
}
