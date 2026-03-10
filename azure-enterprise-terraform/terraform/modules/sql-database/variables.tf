variable "name" {
  type        = string
  description = "SQL server name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Location."
}

variable "sql_version" {
  type        = string
  description = "SQL version."
  default     = "12.0"
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version."
  default     = "1.2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access."
  default     = false
}

variable "azuread_authentication_only" {
  type        = bool
  description = "Only allow Azure AD authentication."
  default     = true
}

variable "azuread_administrator" {
  type = object({
    login_username = string
    object_id      = string
  })
  description = "Azure AD administrator definition."
  default     = null
}

variable "administrator_login" {
  type        = string
  description = "Optional SQL admin login for mixed auth."
  default     = null
}

variable "administrator_login_password" {
  type        = string
  description = "Optional SQL admin password for mixed auth."
  default     = null
  sensitive   = true
}

variable "identity_type" {
  type        = string
  description = "Managed identity type."
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned identity ids."
  default     = []
}

variable "databases" {
  type        = map(any)
  description = "Databases to create."
  default     = {}
}

variable "extended_auditing_policy_enabled" {
  type        = bool
  description = "Enable SQL server extended auditing."
  default     = false
}

variable "extended_auditing_retention_in_days" {
  type        = number
  description = "Retention for SQL extended auditing."
  default     = 90
}

variable "extended_auditing_storage_endpoint" {
  type        = string
  description = "Storage endpoint for SQL extended auditing."
  default     = null
}

variable "extended_auditing_storage_account_access_key" {
  type        = string
  description = "Storage account key for SQL extended auditing."
  default     = null
  sensitive   = true
}

variable "security_alert_policy_enabled" {
  type        = bool
  description = "Enable SQL server security alert policy."
  default     = false
}

variable "security_alert_retention_days" {
  type        = number
  description = "Retention for SQL security alerts."
  default     = 90
}

variable "security_alert_storage_endpoint" {
  type        = string
  description = "Storage endpoint for SQL security alerts."
  default     = null
}

variable "security_alert_storage_account_access_key" {
  type        = string
  description = "Storage account key for SQL security alerts."
  default     = null
  sensitive   = true
}

variable "security_alert_email_account_admins" {
  type        = bool
  description = "Send SQL security alerts to account administrators."
  default     = true
}

variable "security_alert_email_addresses" {
  type        = list(string)
  description = "Additional email addresses for SQL security alerts."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
