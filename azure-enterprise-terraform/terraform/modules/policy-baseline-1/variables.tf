variable "scope_id" { type = string } # management group id
variable "policy_mode" {
  type        = string
  default     = "Audit"
  description = "Audit or Deny"
  validation {
    condition     = contains(["Audit", "Deny"], var.policy_mode)
    error_message = "policy_mode must be Audit or Deny"
  }
}
variable "allowed_locations" { type = list(string) }
variable "required_tags" { type = map(string) } # name => display label
