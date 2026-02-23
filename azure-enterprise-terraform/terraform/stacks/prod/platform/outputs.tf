output "resource_group_name" { value = local.rg_name }
output "subnet_ids" { value = module.network.subnet_ids }
output "aks_name" { value = module.aks.name }
