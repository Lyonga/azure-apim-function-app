output "management_group_ids" {
  description = "Management group resource ids keyed by landing-zone alias."
  value       = module.management_groups.management_group_ids
}

output "root_management_group_id" {
  description = "Tenant root management group id used as the parent scope for the hierarchy."
  value       = var.root_management_group_id
}

output "subscriptions_by_group" {
  description = "Effective subscription placement used for management group associations."
  value       = local.effective_subscriptions_by_group
}
