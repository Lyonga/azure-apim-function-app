output "management_group_ids" {
  value = module.management_groups.management_group_ids
}

output "baseline_policy_set_id" {
  value = azurerm_policy_set_definition.finserv_baseline.id
}
