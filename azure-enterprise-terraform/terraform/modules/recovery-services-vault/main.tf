resource "azurerm_recovery_services_vault" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                          = var.sku
  storage_mode_type            = var.storage_mode_type
  cross_region_restore_enabled = var.cross_region_restore_enabled
  soft_delete_enabled          = true
  tags                         = var.tags

  lifecycle {
    # Azure Backup secure-by-default can force vault soft delete into an "Always on"
    # state that AzureRM 3.x cannot model precisely. Keep soft delete enabled and
    # avoid trying to toggle that platform-managed state on subsequent applies.
    ignore_changes = [soft_delete_enabled]
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
}
