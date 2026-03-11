output "id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "nic_id" {
  value = azurerm_network_interface.this.id
}

output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}

output "identity_principal_id" {
  value = try(azurerm_linux_virtual_machine.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  value = try(azurerm_linux_virtual_machine.this.identity[0].tenant_id, null)
}
