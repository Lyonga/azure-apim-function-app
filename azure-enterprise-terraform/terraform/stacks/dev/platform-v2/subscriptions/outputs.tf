output "subscription_catalog" {
  value = {
    for name, cfg in local.normalized_subscriptions :
    name => {
      management_group_key      = cfg.management_group_key
      existing_subscription_id  = cfg.existing_subscription_id
      subscription_display_name = cfg.subscription_display_name
      alias_resource_id         = try(module.subscription_aliases[name].subscription_resource_id, null)
    }
  }
}

output "subscriptions_by_group" {
  value = local.subscriptions_by_group
}
