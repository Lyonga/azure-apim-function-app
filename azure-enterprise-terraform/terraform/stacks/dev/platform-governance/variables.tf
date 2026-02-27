variable "root_management_group_id" {
  type        = string
  description = "Tenant root MG name/id (often the tenant GUID). Example: '00000000-0000-0000-0000-000000000000'."
}

variable "connectivity_subscription_id" { type = string, default = "" }
variable "management_subscription_id" { type = string, default = "" }
variable "prod_workload_subscription_id" { type = string, default = "" }
variable "nonprod_workload_subscription_id" { type = string, default = "" }

variable "allowed_locations" { type = list(string), default = ["eastus", "centralus"] }

variable "required_tags" {
  type = map(string)
  default = {
    environment = "Environment"
    owner       = "Owner"
    costCenter  = "Cost Center"
    service     = "Service"
  }
}

variable "policy_mode" {
  type    = string
  default = "Audit"
}
