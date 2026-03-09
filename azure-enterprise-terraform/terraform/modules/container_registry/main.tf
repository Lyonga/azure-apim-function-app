resource "azurerm_container_registry" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  export_policy_enabled         = var.export_policy_enabled
  tags                          = var.tags

  retention_policy {
    days    = var.retention_policy_days
    enabled = var.retention_policy_enabled
  }

  trust_policy {
    enabled = var.trust_policy_enabled
  }

  dynamic "georeplications" {
    for_each = var.georeplication_locations
    content {
      location                  = georeplications.value
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = var.zone_redundancy_enabled
      tags                      = var.tags
    }
  }
}
