output "workspace_id" { value = azurerm_log_analytics_workspace.this.id }
output "workspace_name" { value = azurerm_log_analytics_workspace.this.name }
output "workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive = true
}

output "law_id"                   { value = azurerm_log_analytics_workspace.this.id }
output "appi_id"                  { value = azurerm_application_insights.appi.id }
output "appi_instrumentation_key" { value = azurerm_application_insights.appi.instrumentation_key }