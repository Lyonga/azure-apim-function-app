output "resource_group_name" {
  value = module.state_storage.resource_group_name
}

output "storage_account_name" {
  value = module.state_storage.storage_account_name
}

output "container_names" {
  value = module.state_storage.container_names
}
