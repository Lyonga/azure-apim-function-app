# output "resource_group_name" { value = local.rg_name }
output "n" {
  value = module.workload_rg.name
}
output "location" {
  value = module.workload_rg.location
}