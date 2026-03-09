output "resource_group_name" {
  value = module.resource_group.name
}

output "workspace_id" {
  value = module.workspace.workspace_id
}

output "workspace_name" {
  value = module.workspace.workspace_name
}

output "diagnostics_storage_account_id" {
  value = module.diagnostics_archive.account_id
}

output "action_group_id" {
  value = module.action_group.id
}

output "recovery_services_vault_id" {
  value = module.recovery_services_vault.id
}
