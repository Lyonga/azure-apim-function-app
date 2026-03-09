output "id" {
  description = "Windows VM resource ID."
  value       = azurerm_windows_virtual_machine.this.id
}

output "name" {
  description = "Windows VM name."
  value       = azurerm_windows_virtual_machine.this.name
}

output "nic_id" {
  description = "Primary NIC resource ID."
  value       = azurerm_network_interface.this.id
}

output "private_ip_address" {
  description = "Primary private IP address."
  value       = azurerm_network_interface.this.private_ip_address
}

output "admin_username" {
  description = "Configured admin username."
  value       = azurerm_windows_virtual_machine.this.admin_username
}

output "identity_principal_id" {
  description = "Managed identity principal ID when assigned."
  value       = try(azurerm_windows_virtual_machine.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Managed identity tenant ID when assigned."
  value       = try(azurerm_windows_virtual_machine.this.identity[0].tenant_id, null)
}

output "data_disk_ids" {
  description = "Attached managed data disk IDs."
  value       = { for name, disk in azurerm_managed_disk.data : name => disk.id }
}
