resource "azurerm_monitor_diagnostic_setting" "subscription_activity" {
  name                       = var.name
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id

  dynamic "enabled_log" {
    for_each = var.activity_log_categories
    content {
      category = enabled_log.value
    }
  }
}
