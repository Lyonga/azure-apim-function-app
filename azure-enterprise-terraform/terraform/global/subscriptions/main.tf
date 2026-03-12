locals {
  normalized_subscriptions = {
    for name, cfg in var.target_subscriptions :
    name => {
      management_group_key      = cfg.management_group_key
      existing_subscription_id  = trimspace(cfg.existing_subscription_id)
      subscription_display_name = try(cfg.subscription_display_name, name)
    }
  }

  subscription_catalog = {
    for name, cfg in local.normalized_subscriptions :
    name => {
      management_group_key      = cfg.management_group_key
      existing_subscription_id  = cfg.existing_subscription_id
      subscription_display_name = cfg.subscription_display_name
    }
  }

  subscriptions_by_group = {
    for group_key in distinct([
      for cfg in values(local.subscription_catalog) : cfg.management_group_key
    ]) :
    group_key => [
      for cfg in values(local.subscription_catalog) : cfg.existing_subscription_id
      if cfg.management_group_key == group_key && cfg.existing_subscription_id != ""
    ]
  }
}
