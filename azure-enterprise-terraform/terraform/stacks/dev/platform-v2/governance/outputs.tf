output "management_group_ids" {
  value = module.management_groups.management_group_ids
}

output "subscription_id" {
  value = var.subscription_id
}

output "baseline_policy_set_id" {
  value = azurerm_policy_set_definition.finserv_baseline.id
}

output "effective_subscriptions_by_group" {
  value = local.effective_subscriptions_by_group
}
