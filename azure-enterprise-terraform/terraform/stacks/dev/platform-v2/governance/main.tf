module "tags" {
  source              = "../../../../modules/platform-tags"
  environment         = var.environment
  application         = var.application
  created_by          = var.created_by
  business_owner      = var.business_owner
  source_repo         = var.source_repo
  terraform_workspace = var.terraform_workspace
  recovery_tier       = var.recovery_tier
  cost_center         = var.cost_center
  compliance_boundary = var.compliance_boundary
  creation_date_utc   = var.creation_date_utc
  last_modified_utc   = var.last_modified_utc
}

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
  subscriptions_from_state = var.use_subscriptions_state ? try(
    data.terraform_remote_state.subscriptions[0].outputs.subscriptions_by_group,
    {},
  ) : {}

  subscription_group_keys = distinct(concat(
    keys(var.subscriptions_by_group),
    keys(local.subscriptions_from_state),
  ))

  effective_subscriptions_by_group = {
    for key in local.subscription_group_keys :
    key => distinct(concat(
      lookup(var.subscriptions_by_group, key, []),
      lookup(local.subscriptions_from_state, key, []),
    ))
  }
}

module "management_groups" {
  source                   = "../../../../modules/management_groups"
  root_management_group_id = var.root_management_group_id
  prefix                   = var.organization_prefix
  display_name_prefix      = var.organization_display_name
  subscriptions_by_group   = local.effective_subscriptions_by_group
}

locals {
  role_assignments = merge(
    var.platform_deployer_principal_id == "" ? {} : {
      platform_contributor = {
        scope                = module.management_groups.management_group_ids["platform"]
        role_definition_name = "Contributor"
        principal_id         = var.platform_deployer_principal_id
      }
      platform_user_access_admin = {
        scope                = module.management_groups.management_group_ids["platform"]
        role_definition_name = "User Access Administrator"
        principal_id         = var.platform_deployer_principal_id
      }
    },
    var.security_reader_principal_id == "" ? {} : {
      security_reader = {
        scope                = module.management_groups.management_group_ids["security"]
        role_definition_name = "Reader"
        principal_id         = var.security_reader_principal_id
      }
    },
    var.nonprod_workload_deployer_principal_id == "" ? {} : {
      nonprod_contributor = {
        scope                = module.management_groups.management_group_ids["nonprod"]
        role_definition_name = "Contributor"
        principal_id         = var.nonprod_workload_deployer_principal_id
      }
    },
    var.prod_workload_reader_principal_id == "" ? {} : {
      prod_reader = {
        scope                = module.management_groups.management_group_ids["prod"]
        role_definition_name = "Reader"
        principal_id         = var.prod_workload_reader_principal_id
      }
    },
  )
}

resource "azurerm_policy_definition" "allowed_locations" {
  name                = "${var.organization_prefix}-allowed-locations"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Allow approved Azure regions"
  description         = "Denies deployments outside approved Azure regions."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field" = "location"
          "notIn" = var.allowed_locations
        },
        {
          "field"     = "location"
          "notEquals" = "global"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "required_tags" {
  name                = "${var.organization_prefix}-required-tags"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require enterprise tags"
  description         = "Denies resources missing required enterprise tags."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"     = "type"
          "notEquals" = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          "count" = {
            "value" = var.required_tags
            "name"  = "tagName"
            "where" = {
              "field"  = "[concat('tags[', current('tagName'), ']')]"
              "exists" = "false"
            }
          }
          "greater" = 0
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name                = "${var.organization_prefix}-deny-public-ip"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public IP creation"
  description         = "Blocks public IP address resources."

  policy_rule = jsonencode({
    "if" = {
      "field"  = "type"
      "equals" = "Microsoft.Network/publicIPAddresses"
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_storage_public_network" {
  name                = "${var.organization_prefix}-deny-storage-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Deny public network access for storage accounts"
  description         = "Requires storage accounts in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.Storage/storageAccounts"
        },
        {
          "field"     = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_key_vault_public_network" {
  name                = "${var.organization_prefix}-deny-keyvault-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for Key Vault"
  description         = "Requires Key Vaults in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.KeyVault/vaults"
        },
        {
          "field"     = "Microsoft.KeyVault/vaults/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_service_bus_public_network" {
  name                = "${var.organization_prefix}-deny-servicebus-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for Service Bus"
  description         = "Requires Service Bus namespaces in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.ServiceBus/namespaces"
        },
        {
          "field"     = "Microsoft.ServiceBus/namespaces/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_app_configuration_public_network" {
  name                = "${var.organization_prefix}-deny-appconfig-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for App Configuration"
  description         = "Requires App Configuration stores in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.AppConfiguration/configurationStores"
        },
        {
          "field"     = "Microsoft.AppConfiguration/configurationStores/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_sql_public_network" {
  name                = "${var.organization_prefix}-deny-sql-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for SQL servers"
  description         = "Requires Azure SQL servers in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.Sql/servers"
        },
        {
          "field"     = "Microsoft.Sql/servers/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_definition" "deny_webapp_public_network" {
  name                = "${var.organization_prefix}-deny-webapp-public-network"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public network access for App Service workloads"
  description         = "Requires App Service and Function App resources in workload landing zones to disable public network access."

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field"  = "type"
          "equals" = "Microsoft.Web/sites"
        },
        {
          "field"     = "Microsoft.Web/sites/publicNetworkAccess"
          "notEquals" = "Disabled"
        }
      ]
    }
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_policy_set_definition" "finserv_baseline" {
  name                = "${var.organization_prefix}-finserv-baseline"
  display_name        = "FinServ Landing Zone Baseline"
  policy_type         = "Custom"
  management_group_id = module.management_groups.management_group_ids["landing_zones"]

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowedLocations"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.required_tags.id
    reference_id         = "requiredTags"
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
}

resource "azurerm_management_group_policy_assignment" "prod" {
  name                 = "${var.organization_prefix}-prod-baseline"
  display_name         = "Prod Landing Zone Baseline"
  management_group_id  = module.management_groups.management_group_ids["prod"]
  policy_definition_id = azurerm_policy_set_definition.finserv_baseline.id
  metadata             = jsonencode(module.tags.tags)
}

resource "azurerm_management_group_policy_assignment" "nonprod" {
  name                 = "${var.organization_prefix}-nonprod-baseline"
  display_name         = "Nonprod Landing Zone Baseline"
  management_group_id  = module.management_groups.management_group_ids["nonprod"]
  policy_definition_id = azurerm_policy_set_definition.finserv_baseline.id
  metadata             = jsonencode(module.tags.tags)
}

module "role_assignments" {
  source      = "../../../../modules/role-assignments"
  assignments = local.role_assignments
}
