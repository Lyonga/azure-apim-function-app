resource "azurerm_storage_account" "sa" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication

  min_tls_version = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.public_network_access_enabled

  tags = var.tags
}

output "id" { value = azurerm_storage_account.sa.id }
output "name" { value = azurerm_storage_account.sa.name }
output "primary_blob_endpoint" { value = azurerm_storage_account.sa.primary_blob_endpoint }
