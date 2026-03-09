output "id" {
  value = azurerm_application_gateway.this.id
}

output "frontend_ip_configuration_id" {
  value = azurerm_application_gateway.this.frontend_ip_configuration[0].id
}

output "public_ip_address" {
  value = try(azurerm_public_ip.this[0].ip_address, null)
}
