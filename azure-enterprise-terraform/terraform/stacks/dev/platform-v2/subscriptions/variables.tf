variable "subscription_id" {
  type        = string
  description = "Execution subscription used for reading tenant metadata and optional alias creation."
}

variable "target_subscriptions" {
  type = map(object({
    management_group_key      = string
    existing_subscription_id  = optional(string)
    subscription_display_name = optional(string)
    enable_alias_creation     = optional(bool, false)
    billing_scope_id          = optional(string)
    workload                  = optional(string, "Production")
  }))
  description = "Catalog of subscriptions by logical purpose. Existing ids are the source of truth unless alias creation is enabled."
  default     = {}
}
