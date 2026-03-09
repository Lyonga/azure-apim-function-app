output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Log Analytics workspace id."
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Log Analytics workspace name."
}

output "application_insights_id" {
  value       = try(azurerm_application_insights.this[0].id, null)
  description = "Application Insights id."
}

output "application_insights_connection_string" {
  value       = try(azurerm_application_insights.this[0].connection_string, null)
  description = "Application Insights connection string."
  sensitive   = true
}
