variable "subscription_id" {
  type        = string
  description = "Execution subscription used for tenant-level management-group operations."
}

variable "root_management_group_id" {
  type        = string
  description = "Tenant root management group resource id."
}

variable "organization_prefix" {
  type        = string
  description = "Short prefix used for management group names."
  default     = "fin"
}

variable "organization_display_name" {
  type        = string
  description = "Display prefix for management groups."
  default     = "FinServ"
}

variable "subscriptions_by_group" {
  type        = map(list(string))
  description = "Optional local subscription placement keyed by target management-group alias."
  default     = {}
}

variable "use_subscriptions_state" {
  type        = bool
  description = "Read subscription placement from the global subscriptions stack."
  default     = true
}

variable "subscriptions_state_rg" {
  type        = string
  description = "Resource group hosting the global subscriptions state."
  default     = "rg-tfstate-dev"
}

variable "subscriptions_state_sa" {
  type        = string
  description = "Storage account hosting the global subscriptions state."
  default     = "demotest822e"
}

variable "subscriptions_state_container" {
  type        = string
  description = "Container hosting the global subscriptions state."
  default     = "deploy-container"
}

variable "subscriptions_state_key" {
  type        = string
  description = "State blob key for the global subscriptions stack."
  default     = "global/subscriptions.tfstate"
}

variable "subscriptions_state_subscription_id" {
  type        = string
  description = "Subscription containing the global subscriptions state."
  default     = "65ac2b14-e13a-40a0-bb50-93359232816e"
}
