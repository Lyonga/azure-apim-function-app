data "terraform_remote_state" "management_groups" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.management_groups_state_rg
    storage_account_name = var.management_groups_state_sa
    container_name       = var.management_groups_state_container
    key                  = var.management_groups_state_key
    subscription_id      = var.management_groups_state_subscription_id
    use_azuread_auth     = true
  }
}

locals {
  management_group_ids = try(data.terraform_remote_state.management_groups.outputs.management_group_ids, {})
  root_management_group_id = try(
    data.terraform_remote_state.management_groups.outputs.root_management_group_id,
    null,
  )

  dependency_errors = compact([
    length(keys(local.management_group_ids)) > 0 ? null : "Apply global/management-groups before planning or applying global/policy.",
    local.root_management_group_id != null ? null : "Management groups state is missing the root_management_group_id output.",
    contains(keys(local.management_group_ids), "platform") ? null : "Management groups state is missing the platform management group id.",
    contains(keys(local.management_group_ids), "landing_zones") ? null : "Management groups state is missing the landing_zones management group id.",
    contains(keys(local.management_group_ids), "prod") ? null : "Management groups state is missing the prod management group id.",
    contains(keys(local.management_group_ids), "nonprod") ? null : "Management groups state is missing the nonprod management group id.",
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

resource "azurerm_policy_definition" "allowed_locations" {
  name                = "${var.organization_prefix}-allowed-locations"
  management_group_id = local.root_management_group_id
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Allow approved Azure regions"
  description         = "Denies deployments outside approved Azure regions."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = var.allowed_locations
        },
        {
          field     = "location"
          notEquals = "global"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "required_tag" {
  name                = "${var.organization_prefix}-required-tag"
  management_group_id = local.root_management_group_id
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require enterprise tag"
  description         = "Denies resources missing a required enterprise tag."

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag name"
        description = "Name of the required tag."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field     = "type"
          notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          field  = "[concat('tags[', parameters('tagName'), ']')]"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name                = "${var.organization_prefix}-deny-public-ip"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public IP creation"
  description         = "Blocks public IP address resources."

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_storage_public_network" {
  name                = "${var.organization_prefix}-deny-storage-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Deny public network access for storage accounts"
  description         = "Requires storage accounts in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field     = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_key_vault_public_network" {
  name                = "${var.organization_prefix}-deny-keyvault-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for Key Vault"
  description         = "Requires Key Vaults in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.KeyVault/vaults"
        },
        {
          field     = "Microsoft.KeyVault/vaults/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_service_bus_public_network" {
  name                = "${var.organization_prefix}-deny-servicebus-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for Service Bus"
  description         = "Requires Service Bus namespaces in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.ServiceBus/namespaces"
        },
        {
          field     = "Microsoft.ServiceBus/namespaces/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_app_configuration_public_network" {
  name                = "${var.organization_prefix}-deny-appconfig-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for App Configuration"
  description         = "Requires App Configuration stores in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.AppConfiguration/configurationStores"
        },
        {
          field     = "Microsoft.AppConfiguration/configurationStores/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_sql_public_network" {
  name                = "${var.organization_prefix}-deny-sql-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for SQL servers"
  description         = "Requires Azure SQL servers in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Sql/servers"
        },
        {
          field     = "Microsoft.Sql/servers/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_webapp_public_network" {
  name                = "${var.organization_prefix}-deny-webapp-public-network"
  management_group_id = local.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for App Service workloads"
  description         = "Requires App Service and Function App resources in landing zones to disable public network access."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Web/sites"
        },
        {
          field     = "Microsoft.Web/sites/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_set_definition" "platform_foundation" {
  name                = "${var.organization_prefix}-platform-foundation"
  display_name        = "FinServ Platform Foundation"
  policy_type         = "Custom"
  management_group_id = local.management_group_ids["platform"]

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowedLocations"
  }

  dynamic "policy_definition_reference" {
    for_each = toset(var.required_tags)

    content {
      policy_definition_id = azurerm_policy_definition.required_tag.id
      reference_id         = "required-tag-${replace(policy_definition_reference.value, "_", "-")}"
      parameter_values = jsonencode({
        tagName = {
          value = policy_definition_reference.value
        }
      })
    }
  }
}

resource "azurerm_policy_set_definition" "landing_zone_baseline" {
  name                = "${var.organization_prefix}-landing-zone-baseline"
  display_name        = "FinServ Landing Zone Baseline"
  policy_type         = "Custom"
  management_group_id = local.management_group_ids["landing_zones"]

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowedLocations"
  }

  dynamic "policy_definition_reference" {
    for_each = toset(var.required_tags)

    content {
      policy_definition_id = azurerm_policy_definition.required_tag.id
      reference_id         = "required-tag-${replace(policy_definition_reference.value, "_", "-")}"
      parameter_values = jsonencode({
        tagName = {
          value = policy_definition_reference.value
        }
      })
    }
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
    reference_id         = "denyPublicIp"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_storage_public_network.id
    reference_id         = "denyStoragePublicNetwork"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_key_vault_public_network.id
    reference_id         = "denyKeyVaultPublicNetwork"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_service_bus_public_network.id
    reference_id         = "denyServiceBusPublicNetwork"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_app_configuration_public_network.id
    reference_id         = "denyAppConfigurationPublicNetwork"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_sql_public_network.id
    reference_id         = "denySqlPublicNetwork"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_webapp_public_network.id
    reference_id         = "denyWebAppPublicNetwork"
  }

  depends_on = [terraform_data.dependency_guard]
}

resource "azurerm_management_group_policy_assignment" "platform" {
  name                 = "${var.organization_prefix}-platform-foundation"
  display_name         = "Platform Foundation"
  management_group_id  = local.management_group_ids["platform"]
  policy_definition_id = azurerm_policy_set_definition.platform_foundation.id
}

resource "azurerm_management_group_policy_assignment" "prod" {
  name                 = "${var.organization_prefix}-prod-baseline"
  display_name         = "Prod Landing Zone Baseline"
  management_group_id  = local.management_group_ids["prod"]
  policy_definition_id = azurerm_policy_set_definition.landing_zone_baseline.id
}

resource "azurerm_management_group_policy_assignment" "nonprod" {
  name                 = "${var.organization_prefix}-nonprod-baseline"
  display_name         = "Nonprod Landing Zone Baseline"
  management_group_id  = local.management_group_ids["nonprod"]
  policy_definition_id = azurerm_policy_set_definition.landing_zone_baseline.id
}
