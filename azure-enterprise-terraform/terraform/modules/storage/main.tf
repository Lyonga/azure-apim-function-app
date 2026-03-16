#checkov:skip=CKV2_AZURE_33: Private endpoints for this reusable storage module are provisioned in the caller stack or connectivity layer.
#checkov:skip=CKV2_AZURE_1: Customer-managed keys are attached selectively by callers; this base module remains usable for bootstrap and legacy workloads.
#checkov:skip=CKV2_AZURE_40: Some callers, such as Function App runtime storage, still require shared key authorization for compatibility.
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

  dynamic "sas_policy" {
    for_each = var.shared_access_key_enabled ? [1] : []
    content {
      expiration_period = var.sas_expiration_period
      expiration_action = var.sas_expiration_action
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = var.network_bypass
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }
}

resource "azapi_resource" "this" {
  for_each                  = var.containers
  type                      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01"
  name                      = each.key
  parent_id                 = "${azurerm_storage_account.this.id}/blobServices/default"
  schema_validation_enabled = false

  body = {
    properties = {
      publicAccess = (
        each.value.access_type == "blob" ? "Blob" :
        each.value.access_type == "container" ? "Container" :
        "None"
      )
    }
  }
}
