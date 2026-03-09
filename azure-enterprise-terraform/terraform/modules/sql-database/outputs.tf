output "server_id" {
  value       = azurerm_mssql_server.this.id
  description = "SQL server id."
}

output "server_name" {
  value       = azurerm_mssql_server.this.name
  description = "SQL server name."
}

output "database_ids" {
  value       = { for key, database in azurerm_mssql_database.this : key => database.id }
  description = "Database ids."
}
