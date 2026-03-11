variable "environment" {
  type        = string
  description = "Environment tag value."
}

variable "subscription_id" {
  type        = string
  description = "Platform subscription id hosting the bootstrap state resources."
}

variable "application" {
  type        = string
  description = "Application code for the backend resources."
  default     = "terraform-platform"
}

variable "created_by" {
  type        = string
  description = "Provisioning source tag."
  default     = "terraform"
}

variable "location" {
  type        = string
  description = "Azure region for state resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for state."
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique storage account name."
}

variable "containers" {
  type        = list(string)
  description = "Containers to create for remote state."
  default     = ["tfstate"]
}

variable "create_resource_group" {
  type        = bool
  description = "Create the state resource group."
  default     = true
}

variable "account_replication_type" {
  type        = string
  description = "Replication model for the backend account."
  default     = "GRS"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access for the backend account."
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Allow shared key authentication."
  default     = false
}

variable "enable_network_rules" {
  type        = bool
  description = "Enable storage network rules."
  default     = true
}

variable "ip_rules" {
  type        = list(string)
  description = "Optional IP rules for backend access."
  default     = []
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "Optional subnet allow list for backend access."
  default     = []
}

variable "business_owner" {
  type        = string
  description = "Business owner tag."
  default     = "platform"
}

variable "source_repo" {
  type        = string
  description = "Source repository tag."
  default     = "azure-apim-function-app"
}

variable "terraform_workspace" {
  type        = string
  description = "Terraform workspace or stack name."
  default     = "bootstrap-state"
}

variable "recovery_tier" {
  type        = string
  description = "Recovery method tag."
  default     = "terraform"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
  default     = "shared-platform"
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

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags."
  default     = {}
}
