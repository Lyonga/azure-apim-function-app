variable "root_management_group_id" {
  type        = string
  description = "Tenant root management group resource id."
}

variable "subscription_id" {
  type        = string
  description = "Platform subscription id used as the execution context for governance changes."
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

variable "environment" {
  type        = string
  description = "Environment tag."
  default     = "shared"
}

variable "application" {
  type        = string
  description = "Application tag."
  default     = "governance"
}

variable "created_by" {
  type        = string
  description = "Provisioning source tag."
  default     = "terraform"
}

variable "business_owner" {
  type        = string
  description = "Business owner tag."
  default     = "security-engineering"
}

variable "source_repo" {
  type        = string
  description = "Source repository tag."
  default     = "azure-apim-function-app"
}

variable "terraform_workspace" {
  type        = string
  description = "Terraform workspace or stack tag."
  default     = "global-governance"
}

variable "recovery_tier" {
  type        = string
  description = "Recovery tag."
  default     = "terraform"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
  default     = "shared-security"
}

variable "compliance_boundary" {
  type        = string
  description = "Compliance boundary tag."
  default     = "finserv"
}

variable "creation_date_utc" {
  type        = string
  description = "Optional immutable creation timestamp tag."
  default     = null
}

variable "last_modified_utc" {
  type        = string
  description = "Optional last modified timestamp tag."
  default     = null
}

variable "subscriptions_by_group" {
  type        = map(list(string))
  description = "Subscription placement keyed by target management group alias."
  default     = {}
}

variable "use_subscriptions_state" {
  type        = bool
  description = "Read subscription placement from the dedicated subscriptions stack."
  default     = false
}

variable "subscriptions_state_rg" {
  type        = string
  description = "Resource group hosting the subscriptions stack state."
  default     = null
}

variable "subscriptions_state_sa" {
  type        = string
  description = "Storage account hosting the subscriptions stack state."
  default     = null
}

variable "subscriptions_state_container" {
  type        = string
  description = "Container hosting the subscriptions stack state."
  default     = "deploy-container"
}

variable "subscriptions_state_key" {
  type        = string
  description = "State blob key for the subscriptions stack."
  default     = null
}

variable "subscriptions_state_subscription_id" {
  type        = string
  description = "Subscription containing the subscriptions stack remote state."
  default     = null
}

variable "allowed_locations" {
  type        = list(string)
  description = "Allowed Azure regions."
}

variable "required_tags" {
  type        = list(string)
  description = "Required resource tags."
  default = [
    "env",
    "application",
    "created_by",
    "bt_owner",
    "source_repo",
    "tf_workspace",
    "recovery",
    "cost_center",
  ]
}

variable "platform_deployer_principal_id" {
  type        = string
  description = "Principal id for the platform deployment pipeline."
  default     = ""
}

variable "security_reader_principal_id" {
  type        = string
  description = "Principal id for the security reader group or identity."
  default     = ""
}

variable "nonprod_workload_deployer_principal_id" {
  type        = string
  description = "Principal id for the nonprod workload deployment identity."
  default     = ""
}

variable "prod_workload_reader_principal_id" {
  type        = string
  description = "Principal id for a read-only prod workload identity."
  default     = ""
}
