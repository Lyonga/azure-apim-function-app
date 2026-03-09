resource "azurerm_management_group" "platform" {
  name                       = "${var.prefix}-platform"
  display_name               = "${var.display_name_prefix} Platform"
  parent_management_group_id = var.root_management_group_id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "${var.prefix}-connectivity"
  display_name               = "${var.display_name_prefix} Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  name                       = "${var.prefix}-management"
  display_name               = "${var.display_name_prefix} Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  name                       = "${var.prefix}-identity"
  display_name               = "${var.display_name_prefix} Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "security" {
  name                       = "${var.prefix}-security"
  display_name               = "${var.display_name_prefix} Security"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "landing_zones" {
  name                       = "${var.prefix}-landing-zones"
  display_name               = "${var.display_name_prefix} Landing Zones"
  parent_management_group_id = var.root_management_group_id
}

resource "azurerm_management_group" "prod" {
  name                       = "${var.prefix}-prod"
  display_name               = "${var.display_name_prefix} Prod"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "nonprod" {
  name                       = "${var.prefix}-nonprod"
  display_name               = "${var.display_name_prefix} Nonprod"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "sandbox" {
  name                       = "${var.prefix}-sandbox"
  display_name               = "${var.display_name_prefix} Sandbox"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "decommissioned" {
  name                       = "${var.prefix}-decommissioned"
  display_name               = "${var.display_name_prefix} Decommissioned"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

locals {
  management_group_lookup = {
    platform       = azurerm_management_group.platform.id
    connectivity   = azurerm_management_group.connectivity.id
    management     = azurerm_management_group.management.id
    identity       = azurerm_management_group.identity.id
    security       = azurerm_management_group.security.id
    landing_zones  = azurerm_management_group.landing_zones.id
    prod           = azurerm_management_group.prod.id
    nonprod        = azurerm_management_group.nonprod.id
    sandbox        = azurerm_management_group.sandbox.id
    decommissioned = azurerm_management_group.decommissioned.id
  }

  subscription_links = {
    for item in flatten([
      for group_key, subscription_ids in var.subscriptions_by_group : [
        for subscription_id in subscription_ids : {
          key             = "${group_key}-${subscription_id}"
          group_key       = group_key
          subscription_id = subscription_id
        }
      ]
    ]) : item.key => item
  }
}

resource "azurerm_management_group_subscription_association" "this" {
  for_each            = local.subscription_links
  management_group_id = local.management_group_lookup[each.value.group_key]
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
}
