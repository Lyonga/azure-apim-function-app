variable "enable" {
  type    = bool
  default = false
}
variable "subscription_display_name" { type = string default = null }
variable "billing_scope_id" { type = string default = null } # depends on EA/MCA
variable "workload" { type = string default = "Production" } # Production/DevTest
