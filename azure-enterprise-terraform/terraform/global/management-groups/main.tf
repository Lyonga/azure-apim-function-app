data "terraform_remote_state" "subscriptions" {
  count   = var.use_subscriptions_state ? 1 : 0
  backend = "azurerm"

  config = {
    resource_group_name  = var.subscriptions_state_rg
    storage_account_name = var.subscriptions_state_sa
    container_name       = var.subscriptions_state_container
    key                  = var.subscriptions_state_key
    subscription_id      = var.subscriptions_state_subscription_id
    use_azuread_auth     = true
  }
}

locals {
  subscriptions_from_state = var.use_subscriptions_state ? {
    for key, ids in try(data.terraform_remote_state.subscriptions[0].outputs.subscriptions_by_group, {}) :
    key => tolist(ids)
  } : {}

  subscription_group_keys = distinct(concat(
    keys(var.subscriptions_by_group),
    keys(local.subscriptions_from_state),
  ))

  effective_subscriptions_by_group = {
    for key in local.subscription_group_keys :
    key => distinct(concat(
      lookup(var.subscriptions_by_group, key, []),
      try(local.subscriptions_from_state[key], tolist([])),
    ))
  }

  dependency_errors = compact([
    !var.use_subscriptions_state ? null : length(keys(local.subscriptions_from_state)) > 0 ? null : "Apply global/subscriptions before planning or applying global/management-groups.",
  ])
}

resource "terraform_data" "dependency_guard" {
  input = true

  lifecycle {
    precondition {
      condition     = length(local.dependency_errors) == 0
      error_message = join("\n", local.dependency_errors)
    }
  }
}

module "management_groups" {
  source                   = "../../modules/management_groups"
  root_management_group_id = var.root_management_group_id
  prefix                   = var.organization_prefix
  display_name_prefix      = var.organization_display_name
  subscriptions_by_group   = local.effective_subscriptions_by_group

  depends_on = [terraform_data.dependency_guard]
}
