output "account_id" { value = azurerm_storage_account.this.id }
output "account_name" { value = azurerm_storage_account.this.name }
output "primary_blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
output "container_names" { value = keys(azurerm_storage_container.this) }
