output "id" {
  value = azurerm_bastion_host.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}
