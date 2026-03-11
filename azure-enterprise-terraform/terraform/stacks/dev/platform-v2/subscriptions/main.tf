locals {
  normalized_subscriptions = {
    for name, cfg in var.target_subscriptions :
    name => {
      management_group_key      = cfg.management_group_key
      existing_subscription_id  = try(cfg.existing_subscription_id, null)
      subscription_display_name = try(cfg.subscription_display_name, name)
      enable_alias_creation     = try(cfg.enable_alias_creation, false)
      billing_scope_id          = try(cfg.billing_scope_id, null)
      workload                  = try(cfg.workload, "Production")
    }
  }

  resolved_subscription_catalog = {
    for name, cfg in local.normalized_subscriptions :
    name => {
      management_group_key      = cfg.management_group_key
      existing_subscription_id  = cfg.existing_subscription_id != null && trimspace(cfg.existing_subscription_id) != "" ? trimspace(cfg.existing_subscription_id) : try(module.subscription_aliases[name].subscription_id, null)
      subscription_display_name = cfg.subscription_display_name
      alias_resource_id         = try(module.subscription_aliases[name].subscription_resource_id, null)
      provisioning_state        = try(module.subscription_aliases[name].provisioning_state, null)
      created_via_alias         = cfg.enable_alias_creation
    }
  }

  subscriptions_by_group = {
    for group_key in distinct([for cfg in values(local.resolved_subscription_catalog) : cfg.management_group_key]) :
    group_key => [
      for cfg in values(local.resolved_subscription_catalog) : cfg.existing_subscription_id
      if cfg.management_group_key == group_key && cfg.existing_subscription_id != null && trimspace(cfg.existing_subscription_id) != ""
    ]
  }
}

module "subscription_aliases" {
  for_each = {
    for name, cfg in local.normalized_subscriptions :
    name => cfg if cfg.enable_alias_creation
  }

  source = "../../../../modules/subscription"

  enable                    = true
  subscription_display_name = each.value.subscription_display_name
  billing_scope_id          = each.value.billing_scope_id
  workload                  = each.value.workload
}
