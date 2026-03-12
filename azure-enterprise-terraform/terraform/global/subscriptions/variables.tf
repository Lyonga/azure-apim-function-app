variable "subscription_id" {
  type        = string
  description = "Execution subscription used to write the catalog state."
}

variable "target_subscriptions" {
  type = map(object({
    management_group_key      = string
    existing_subscription_id  = string
    subscription_display_name = optional(string)
  }))
  description = "Existing subscriptions keyed by logical landing-zone role."
  default     = {}
}
