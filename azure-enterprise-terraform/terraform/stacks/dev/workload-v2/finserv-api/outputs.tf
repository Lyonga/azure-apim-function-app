output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = var.subscription_id
}

output "spoke_vnet_id" {
  value = module.spoke_network.vnet_id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "function_app_name" {
  value = try(module.function_app[0].name, null)
}

output "demo_windows_vm_id" {
  value = try(module.demo_windows_vm[0].id, null)
}

output "demo_windows_vm_name" {
  value = try(module.demo_windows_vm[0].name, null)
}

output "demo_windows_vm_private_ip" {
  value = try(module.demo_windows_vm[0].private_ip_address, null)
}

output "demo_windows_vm_identity_principal_id" {
  value = try(module.demo_windows_vm[0].identity_principal_id, null)
}

output "app_configuration_endpoint" {
  value = try(module.app_configuration[0].endpoint, null)
}

output "service_bus_namespace" {
  value = try(module.service_bus[0].name, null)
}

output "sql_server_name" {
  value = try(module.sql_database[0].server_name, null)
}

output "api_management_name" {
  value = try(module.api_management[0].name, null)
}

output "effective_app_identity_id" {
  value = local.effective_app_identity.id
}

output "effective_app_identity_principal_id" {
  value = local.effective_app_identity.principal_id
}

output "effective_app_identity_client_id" {
  value = local.effective_app_identity.client_id
}
