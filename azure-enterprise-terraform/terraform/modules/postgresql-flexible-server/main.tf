resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.version
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled
  administrator_login           = var.authentication.password_auth_enabled ? var.administrator_login : null
  administrator_password        = var.authentication.password_auth_enabled ? var.administrator_password : null
  zone                          = var.zone
  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  tags                          = var.tags

  authentication {
    active_directory_auth_enabled = var.authentication.active_directory_auth_enabled
    password_auth_enabled         = var.authentication.password_auth_enabled
    tenant_id                     = var.authentication.active_directory_auth_enabled ? var.authentication.tenant_id : null
  }

  dynamic "high_availability" {
    for_each = var.high_availability == null ? [] : [var.high_availability]
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = try(high_availability.value.standby_availability_zone, null)
    }
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = var.databases
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = try(each.value.charset, "UTF8")
  collation = try(each.value.collation, "en_US.utf8")
}
