output "id" {
  value       = azurerm_app_configuration.this.id
  description = "App Configuration id."
}

output "endpoint" {
  value       = azurerm_app_configuration.this.endpoint
  description = "App Configuration endpoint."
}

output "name" {
  value       = azurerm_app_configuration.this.name
  description = "App Configuration name."
}
