output "management_group_ids" {
  value       = local.management_group_ids
  description = "Management-group ids consumed from the management-groups state."
}

output "policy_set_ids" {
  value = {
    platform_foundation   = azurerm_policy_set_definition.platform_foundation.id
    landing_zone_baseline = azurerm_policy_set_definition.landing_zone_baseline.id
  }
  description = "Policy set definition ids keyed by initiative alias."
}
