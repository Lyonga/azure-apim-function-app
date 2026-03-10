#checkov:skip=CKV2_AZURE_45: Private endpoints for SQL are created by workload stacks that consume this reusable module.
resource "azurerm_mssql_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.sql_version
  administrator_login           = var.azuread_authentication_only ? null : var.administrator_login
  administrator_login_password  = var.azuread_authentication_only ? null : var.administrator_login_password
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator == null ? [] : [var.azuread_administrator]
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      azuread_authentication_only = var.azuread_authentication_only
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  count = var.extended_auditing_policy_enabled && var.extended_auditing_storage_endpoint != null && var.extended_auditing_storage_account_access_key != null ? 1 : 0

  server_id                  = azurerm_mssql_server.this.id
  enabled                    = true
  log_monitoring_enabled     = true
  retention_in_days          = var.extended_auditing_retention_in_days
  storage_endpoint           = var.extended_auditing_storage_endpoint
  storage_account_access_key = var.extended_auditing_storage_account_access_key
}

resource "azurerm_mssql_server_security_alert_policy" "this" {
  count = var.security_alert_policy_enabled && var.security_alert_storage_endpoint != null && var.security_alert_storage_account_access_key != null ? 1 : 0

  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.this.name
  state                      = "Enabled"
  retention_days             = var.security_alert_retention_days
  storage_endpoint           = var.security_alert_storage_endpoint
  storage_account_access_key = var.security_alert_storage_account_access_key
  email_account_admins       = var.security_alert_email_account_admins
  email_addresses            = var.security_alert_email_addresses
}

resource "azurerm_mssql_database" "this" {
  for_each       = var.databases
  name           = each.key
  server_id      = azurerm_mssql_server.this.id
  sku_name       = try(each.value.sku_name, "GP_S_Gen5_2")
  max_size_gb    = try(each.value.max_size_gb, 32)
  zone_redundant = true
  ledger_enabled = true
  collation      = try(each.value.collation, null)
  read_scale     = try(each.value.read_scale, false)
  tags           = var.tags
}
