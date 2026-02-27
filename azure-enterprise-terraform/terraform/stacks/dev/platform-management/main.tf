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
  service        = "mgmt"
  location_short = var.location_short
}

locals {
  tags = merge(var.tags, {
    environment = var.environment
    service     = "platform-management"
  })
}

module "rg" {
  source   = "../../modules/resource-group"
  name     = module.naming.rg_name
  location = var.location
  tags     = local.tags
}

module "law" {
  source              = "../../modules/log-analytics"
  name                = module.naming.law_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = local.tags
  retention_in_days   = var.log_analytics_retention_days
}

output "log_analytics_workspace_id" { value = module.law.id }
output "log_analytics_workspace_name" { value = module.law.name }
