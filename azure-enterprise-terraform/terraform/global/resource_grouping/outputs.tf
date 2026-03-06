# output "resource_group_name" { value = local.rg_name }
output "workload_rg_name" {
  value = module.workload_rg.name
}
output "workload_rg_location" {
  value = module.workload_rg.location
}