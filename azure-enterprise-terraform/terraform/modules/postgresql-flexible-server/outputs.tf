output "id" {
  value = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_ids" {
  value = { for key, db in azurerm_postgresql_flexible_server_database.this : key => db.id }
}
