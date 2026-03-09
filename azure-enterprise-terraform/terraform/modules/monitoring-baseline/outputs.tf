output "diagnostic_setting_id" {
  value       = azurerm_monitor_diagnostic_setting.subscription_activity.id
  description = "Subscription activity diagnostic setting id."
}
