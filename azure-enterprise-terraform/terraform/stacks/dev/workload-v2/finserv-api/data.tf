data "azurerm_client_config" "current" {}

data "terraform_remote_state" "subscriptions" {
  count   = var.use_subscriptions_state ? 1 : 0
  backend = "azurerm"

  config = merge(
    {
      resource_group_name  = var.subscriptions_state_rg
      storage_account_name = var.subscriptions_state_sa
      container_name       = var.subscriptions_state_container
      key                  = var.subscriptions_state_key
      use_azuread_auth     = true
    },
    coalesce(var.subscriptions_state_subscription_id, var.platform_state_subscription_id) == null ? {} : {
      subscription_id = coalesce(var.subscriptions_state_subscription_id, var.platform_state_subscription_id)
    }
  )
}

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

locals {
  subscriptions_outputs = var.use_subscriptions_state ? try(data.terraform_remote_state.subscriptions[0].outputs, {}) : {}
  subscriptions_catalog = try(local.subscriptions_outputs.subscription_catalog, {})
  expected_subscription_id = try(
    local.subscriptions_catalog[var.subscription_catalog_entry_key].existing_subscription_id,
    null,
  )

  connectivity_outputs = try(data.terraform_remote_state.connectivity.outputs, {})
  management_outputs   = try(data.terraform_remote_state.management.outputs, {})
  identity_outputs     = var.use_shared_identity_services ? try(data.terraform_remote_state.identity[0].outputs, {}) : {}

  _validate_subscription_catalog = [
    !var.use_subscriptions_state ? null : length(keys(local.subscriptions_catalog)) > 0 ? null : throw("Apply platform-v2/subscriptions before planning workload-v2/finserv-api, or disable use_subscriptions_state if you intentionally are not using the central subscription catalog."),
    !var.use_subscriptions_state ? null : local.expected_subscription_id != null ? null : throw("The subscriptions stack does not contain an entry for subscription_catalog_entry_key = " + var.subscription_catalog_entry_key + "."),
    !var.use_subscriptions_state || local.expected_subscription_id == var.subscription_id ? null : throw("The workload stack subscription_id does not match the central subscriptions catalog."),
  ]

  _validate_remote_state_dependencies = [
    length(keys(local.connectivity_outputs)) > 0 ? null : throw("Apply platform-v2/connectivity before planning workload-v2/finserv-api. Reading the state blob alone is not enough; the stack must be applied so outputs are written to state."),
    contains(keys(local.connectivity_outputs), "resource_group_name") ? null : throw("Connectivity state is missing resource_group_name. Apply platform-v2/connectivity so outputs are persisted."),
    contains(keys(local.connectivity_outputs), "hub_vnet_id") ? null : throw("Connectivity state is missing hub_vnet_id. Apply platform-v2/connectivity so outputs are persisted."),
    contains(keys(local.connectivity_outputs), "hub_vnet_name") ? null : throw("Connectivity state is missing hub_vnet_name. Apply platform-v2/connectivity so outputs are persisted."),
    contains(keys(local.connectivity_outputs), "private_dns_zone_ids") ? null : throw("Connectivity state is missing private_dns_zone_ids. Apply platform-v2/connectivity so outputs are persisted."),
    contains(keys(local.connectivity_outputs), "private_dns_zone_names") ? null : throw("Connectivity state is missing private_dns_zone_names. Apply platform-v2/connectivity so outputs are persisted."),
    length(keys(local.management_outputs)) > 0 ? null : throw("Apply platform-v2/management before planning workload-v2/finserv-api."),
    contains(keys(local.management_outputs), "workspace_id") ? null : throw("Management state is missing workspace_id. Apply platform-v2/management so outputs are persisted."),
    contains(keys(local.management_outputs), "resource_group_name") ? null : throw("Management state is missing resource_group_name. Apply platform-v2/management so outputs are persisted."),
    !var.use_shared_identity_services ? null : length(keys(local.identity_outputs)) > 0 ? null : throw("Apply platform-v2/identity before planning workload-v2/finserv-api when use_shared_identity_services = true."),
    !var.use_shared_identity_services || contains(keys(local.identity_outputs), "shared_identity_ids") ? null : throw("Identity state is missing shared_identity_ids. Apply platform-v2/identity so outputs are persisted."),
    !var.use_shared_identity_services || contains(keys(local.identity_outputs), "shared_identity_client_ids") ? null : throw("Identity state is missing shared_identity_client_ids. Apply platform-v2/identity so outputs are persisted."),
    !var.use_shared_identity_services || contains(keys(local.identity_outputs), "shared_identity_principal_ids") ? null : throw("Identity state is missing shared_identity_principal_ids. Apply platform-v2/identity so outputs are persisted."),
    !var.use_shared_identity_services || contains(keys(local.identity_outputs), "shared_identity_names") ? null : throw("Identity state is missing shared_identity_names. Apply platform-v2/identity so outputs are persisted."),
    !var.use_shared_identity_services || contains(keys(local.identity_outputs), "shared_services_cmk_key_id") ? null : throw("Identity state is missing shared_services_cmk_key_id. Apply platform-v2/identity so outputs are persisted."),
  ]
}
