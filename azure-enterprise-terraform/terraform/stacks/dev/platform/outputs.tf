output "resource_group_name" { value = local.rg_name }
output "location" { value = var.location }

output "vnet_name" { value = module.network.vnet_name }
output "subnet_ids" { value = module.network.subnet_ids }

output "keyvault_uri" { value = module.keyvault.vault_uri }
output "storage_account_name" { value = module.storage.account_name }
output "acr_login_server" { value = module.acr.login_server }
output "aks_name" { value = module.aks.name }
output "log_analytics_workspace_id" { value = module.log_analytics.workspace_id }
