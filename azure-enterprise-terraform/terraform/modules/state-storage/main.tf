resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

#checkov:skip=CKV2_AZURE_33: The bootstrap backend cannot depend on private endpoints before the connectivity layer exists.
#checkov:skip=CKV2_AZURE_1: The bootstrap backend intentionally avoids a CMK dependency cycle during first-time state provisioning.
resource "azurerm_storage_account" "this" {
  name                              = var.storage_account_name
  resource_group_name               = local.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = var.account_replication_type
  account_kind                      = "StorageV2"
  min_tls_version                   = var.min_tls_version
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = true
  tags                              = var.tags

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

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

#checkov:skip=CKV2_AZURE_21: Blob insights for the bootstrap state container are handled outside of the backend bootstrap path.
resource "azurerm_storage_container" "this" {
  for_each             = toset(var.containers)
  name                 = each.value
  storage_account_name = azurerm_storage_account.this.name
}
