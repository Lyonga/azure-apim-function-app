output "subscription_catalog" {
  description = "Subscription catalog keyed by logical landing-zone role."
  value       = local.subscription_catalog
}

output "subscriptions_by_group" {
  description = "Subscription ids grouped by target management-group alias."
  value       = local.subscriptions_by_group
}
