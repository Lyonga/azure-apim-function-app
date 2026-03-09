resource "azurerm_storage_account" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  min_tls_version                   = var.min_tls_version
  allow_nested_items_to_be_public   = var.allow_blob_public_access
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  tags                              = var.tags

  blob_properties {
    versioning_enabled  = var.versioning_enabled
    change_feed_enabled = var.change_feed_enabled

    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = var.queue_logging_retention_days
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = var.network_bypass
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }
}

resource "azurerm_storage_container" "this" {
  for_each             = var.containers
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
}
