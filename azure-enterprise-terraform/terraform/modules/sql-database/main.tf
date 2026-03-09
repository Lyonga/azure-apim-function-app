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

resource "azurerm_mssql_database" "this" {
  for_each       = var.databases
  name           = each.key
  server_id      = azurerm_mssql_server.this.id
  sku_name       = try(each.value.sku_name, "S0")
  max_size_gb    = try(each.value.max_size_gb, 32)
  zone_redundant = try(each.value.zone_redundant, false)
  collation      = try(each.value.collation, null)
  read_scale     = try(each.value.read_scale, false)
  tags           = var.tags
}
