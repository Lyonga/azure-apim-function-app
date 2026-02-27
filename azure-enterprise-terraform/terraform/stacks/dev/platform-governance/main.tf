terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
  }
}

provider "azurerm" { features {} }

# IMPORTANT:
# Azure already has a tenant root MG. You typically manage child MGs.
data "azurerm_management_group" "root" {
  name = var.root_management_group_id
}

resource "azurerm_management_group" "platform" {
  display_name               = "platform"
  parent_management_group_id = data.azurerm_management_group.root.id
}

resource "azurerm_management_group" "landing_zones" {
  display_name               = "landing-zones"
  parent_management_group_id = data.azurerm_management_group.root.id
}

resource "azurerm_management_group" "prod" {
  display_name               = "prod"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "nonprod" {
  display_name               = "nonprod"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Optional subscription association (existing subscriptions)
resource "azurerm_management_group_subscription_association" "connectivity" {
  count              = var.connectivity_subscription_id != "" ? 1 : 0
  management_group_id = azurerm_management_group.platform.id
  subscription_id     = "/subscriptions/${var.connectivity_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "management" {
  count              = var.management_subscription_id != "" ? 1 : 0
  management_group_id = azurerm_management_group.platform.id
  subscription_id     = "/subscriptions/${var.management_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "prod_workloads" {
  count              = var.prod_workload_subscription_id != "" ? 1 : 0
  management_group_id = azurerm_management_group.prod.id
  subscription_id     = "/subscriptions/${var.prod_workload_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "nonprod_workloads" {
  count              = var.nonprod_workload_subscription_id != "" ? 1 : 0
  management_group_id = azurerm_management_group.nonprod.id
  subscription_id     = "/subscriptions/${var.nonprod_workload_subscription_id}"
}

# Baseline policy assignments at MG scope
module "policy_prod" {
  source           = "../../modules/policy-baseline"
  scope_id         = azurerm_management_group.prod.id
  policy_mode      = var.policy_mode
  allowed_locations = var.allowed_locations
  required_tags    = var.required_tags
}

module "policy_nonprod" {
  source           = "../../modules/policy-baseline"
  scope_id         = azurerm_management_group.nonprod.id
  policy_mode      = var.policy_mode
  allowed_locations = var.allowed_locations
  required_tags    = var.required_tags
}

output "mg_platform_id" { value = azurerm_management_group.platform.id }
output "mg_prod_id" { value = azurerm_management_group.prod.id }
output "mg_nonprod_id" { value = azurerm_management_group.nonprod.id }
