variable "subscription_id" {
  type        = string
  description = "Execution subscription used for reading tenant metadata and writing the subscription catalog state."
}

variable "target_subscriptions" {
  type = map(object({
    management_group_key      = string
    existing_subscription_id  = string
    subscription_display_name = optional(string)
  }))
  description = "Catalog of existing subscriptions by logical purpose."
  default     = {}
}
