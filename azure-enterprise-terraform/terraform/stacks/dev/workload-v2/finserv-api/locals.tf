locals {
  api_spec_path = var.api_spec_path != null ? abspath(var.api_spec_path) : abspath("${path.root}/../../../api-spec.yml")

  app_subnet_nsg_rules = [
    {
      name                       = "allow-vnet-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "deny-internet-inbound"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
  ]

  integration_subnet_nsg_rules = [
    {
      name                       = "allow-azuremonitor-outbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureMonitor"
    },
    {
      name                       = "allow-storage-outbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "Storage"
    },
    {
      name                       = "allow-keyvault-outbound"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureKeyVault"
    },
    {
      name                       = "allow-sql-outbound"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "1433"
      source_address_prefix      = "*"
      destination_address_prefix = "Sql"
    },
    {
      name                       = "deny-internet-outbound"
      priority                   = 400
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    },
  ]

  data_subnet_nsg_rules = [
    {
      name                       = "allow-vnet-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "deny-internet-inbound"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
  ]

  spoke_subnets = merge(
    {
      app = {
        address_prefixes = [var.app_subnet_cidr]
        nsg_rules        = local.app_subnet_nsg_rules
      }
      integration = {
        address_prefixes = [var.integration_subnet_cidr]
        nsg_rules        = local.integration_subnet_nsg_rules
      }
      data = {
        address_prefixes = [var.data_subnet_cidr]
        nsg_rules        = local.data_subnet_nsg_rules
      }
      private-endpoints = {
        address_prefixes                          = [var.private_endpoints_subnet_cidr]
        private_endpoint_network_policies_enabled = false
        nsg_rules                                 = []
      }
    },
    var.enable_apim ? {
      apim = {
        address_prefixes = [var.apim_subnet_cidr]
        nsg_rules        = []
      }
    } : {},
  )

  storage_private_endpoint_targets = {
    blob = {
      dns_key           = "blob"
      subresource_names = ["blob"]
    }
    file = {
      dns_key           = "file"
      subresource_names = ["file"]
    }
    queue = {
      dns_key           = "queue"
      subresource_names = ["queue"]
    }
    table = {
      dns_key           = "table"
      subresource_names = ["table"]
    }
  }

  workload_role_assignments = merge(
    {
      function_keyvault_reader = {
        scope                = module.key_vault.id
        role_definition_name = "Key Vault Secrets User"
        principal_id         = module.function_app.principal_id
      }
    },
    var.enable_app_configuration ? {
      function_appconfig_reader = {
        scope                = module.app_configuration[0].id
        role_definition_name = "App Configuration Data Reader"
        principal_id         = module.function_app.principal_id
      }
    } : {},
    var.enable_service_bus ? {
      function_servicebus_sender = {
        scope                = module.service_bus[0].id
        role_definition_name = "Azure Service Bus Data Sender"
        principal_id         = module.function_app.principal_id
      }
      function_servicebus_receiver = {
        scope                = module.service_bus[0].id
        role_definition_name = "Azure Service Bus Data Receiver"
        principal_id         = module.function_app.principal_id
      }
    } : {},
  )
}
