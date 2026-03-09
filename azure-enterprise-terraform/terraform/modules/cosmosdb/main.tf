resource "azurerm_cosmosdb_account" "this" {
  name                               = var.name
  location                           = var.failover_locations[0]
  resource_group_name                = var.resource_group_name
  offer_type                         = "Standard"
  kind                               = var.kind
  key_vault_key_id                   = var.key_vault_key_id
  local_authentication_disabled      = var.local_authentication_disabled
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  default_identity_type              = var.default_identity_type
  minimal_tls_version                = var.minimal_tls_version
  public_network_access_enabled      = var.public_network_access_enabled
  is_virtual_network_filter_enabled  = var.is_virtual_network_filter_enabled
  tags                               = var.tags

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
  }

  dynamic "geo_location" {
    for_each = var.failover_locations
    content {
      location          = geo_location.value
      failover_priority = index(var.failover_locations, geo_location.value)
    }
  }

  backup {
    type                = var.backup_type
    storage_redundancy  = var.backup_storage_redundancy
    interval_in_minutes = var.backup_type == "Periodic" ? var.backup_interval_in_minutes : null
    retention_in_hours  = var.backup_type == "Periodic" ? var.backup_retention_in_hours : null
    tier                = var.backup_type == "Continuous" ? var.continuous_backup_tier : null
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
}
