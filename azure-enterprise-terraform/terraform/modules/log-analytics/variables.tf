variable "name" {
  type        = string
  description = "Workspace name."
}

variable "resource_group_name" {
  type        = string
  description = "Workspace resource group."
}

variable "location" {
  type        = string
  description = "Workspace location."
}

variable "sku" {
  type        = string
  description = "Workspace SKU."
  default     = "PerGB2018"
}

variable "retention_in_days" {
  type        = number
  description = "Workspace retention."
  default     = 30
}

variable "application_insights_name" {
  type        = string
  description = "Optional Application Insights resource name."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
