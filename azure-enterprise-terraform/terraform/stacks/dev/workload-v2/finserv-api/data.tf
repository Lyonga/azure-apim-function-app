data "azurerm_client_config" "current" {}

data "terraform_remote_state" "connectivity" {
  backend = "azurerm"

  config = merge(
    {
      resource_group_name  = var.connectivity_state_rg
      storage_account_name = var.connectivity_state_sa
      container_name       = var.connectivity_state_container
      key                  = var.connectivity_state_key
      use_azuread_auth     = true
    },
    coalesce(var.connectivity_state_subscription_id, var.platform_state_subscription_id) == null ? {} : {
      subscription_id = coalesce(var.connectivity_state_subscription_id, var.platform_state_subscription_id)
    }
  )
}

data "terraform_remote_state" "management" {
  backend = "azurerm"

  config = merge(
    {
      resource_group_name  = var.management_state_rg
      storage_account_name = var.management_state_sa
      container_name       = var.management_state_container
      key                  = var.management_state_key
      use_azuread_auth     = true
    },
    coalesce(var.management_state_subscription_id, var.platform_state_subscription_id) == null ? {} : {
      subscription_id = coalesce(var.management_state_subscription_id, var.platform_state_subscription_id)
    }
  )
}

data "terraform_remote_state" "identity" {
  count   = var.use_shared_identity_services ? 1 : 0
  backend = "azurerm"

  config = merge(
    {
      resource_group_name  = coalesce(var.identity_state_rg, var.management_state_rg)
      storage_account_name = coalesce(var.identity_state_sa, var.management_state_sa)
      container_name       = var.identity_state_container
      key                  = coalesce(var.identity_state_key, "stacks/dev/platform-v2/identity.tfstate")
      use_azuread_auth     = true
    },
    coalesce(var.identity_state_subscription_id, var.platform_state_subscription_id) == null ? {} : {
      subscription_id = coalesce(var.identity_state_subscription_id, var.platform_state_subscription_id)
    }
  )
}
