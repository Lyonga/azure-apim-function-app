output "id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "Identity id."
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Identity client id."
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Identity principal id."
}

output "tenant_id" {
  value       = azurerm_user_assigned_identity.this.tenant_id
  description = "Identity tenant id."
}
