variable "name" {
  type        = string
  description = "Diagnostic setting name."
}

variable "subscription_id" {
  type        = string
  description = "Subscription id to export activity logs from."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Destination Log Analytics workspace id."
}

variable "storage_account_id" {
  type        = string
  description = "Optional destination storage account id."
  default     = null
}

variable "activity_log_categories" {
  type        = list(string)
  description = "Activity log categories to export."
  default = [
    "Administrative",
    "Security",
    "ServiceHealth",
    "Alert",
    "Recommendation",
    "Policy",
    "Autoscale",
    "ResourceHealth",
  ]
}
