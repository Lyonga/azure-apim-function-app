output "id" {
  value       = azurerm_resource_group.this.id
  description = "Resource Group ARM resource ID (/subscriptions/.../resourceGroups/...)"
}

output "name" {
  value       = azurerm_resource_group.this.name
  description = "Resource Group name"
}

output "location" {
  value       = azurerm_resource_group.this.location
  description = "Resource Group location"
}