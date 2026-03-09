output "resource_group_name" {
  value       = local.resource_group_name
  description = "State resource group name."
}

output "storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "State storage account id."
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "State storage account name."
}

output "container_names" {
  value       = sort([for container in azurerm_storage_container.this : container.name])
  description = "Provisioned backend container names."
}
