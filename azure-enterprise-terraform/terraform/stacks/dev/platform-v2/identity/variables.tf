variable "environment" {
  type        = string
  description = "Environment tag."
}

variable "subscription_id" {
  type        = string
  description = "Identity subscription id."
}

variable "application" {
  type        = string
  description = "Application code."
  default     = "identity"
}

variable "created_by" {
  type        = string
  description = "Provisioning source tag."
  default     = "terraform"
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Identity resource group."
}

variable "vnet_name" {
  type        = string
  description = "Identity/shared-services VNet name."
}

variable "address_space" {
  type        = list(string)
  description = "Identity VNet CIDR ranges."
}

variable "services_subnet_cidr" {
  type        = string
  description = "Shared identity services subnet CIDR."
  default     = "10.30.1.0/24"
}

variable "private_endpoints_subnet_cidr" {
  type        = string
  description = "Private endpoints subnet CIDR."
  default     = "10.30.10.0/24"
}

variable "key_vault_name" {
  type        = string
  description = "Shared services Key Vault name."
}

variable "shared_identity_names" {
  type        = map(string)
  description = "Shared user-assigned identities keyed by logical role."
  default = {
    workload_runtime = "uai-shared-workload-runtime"
  }
}

variable "business_owner" {
  type        = string
  description = "Business owner tag."
  default     = "identity-engineering"
}

variable "source_repo" {
  type        = string
  description = "Source repository tag."
  default     = "azure-apim-function-app"
}

variable "terraform_workspace" {
  type        = string
  description = "Terraform workspace or stack name."
  default     = "platform-identity"
}

variable "recovery_tier" {
  type        = string
  description = "Recovery method tag."
  default     = "terraform"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
  default     = "shared-identity"
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

variable "platform_state_subscription_id" {
  type        = string
  description = "Optional shared subscription id hosting platform remote state backends."
  default     = null
}

variable "connectivity_state_rg" {
  type        = string
  description = "Connectivity state resource group."
}

variable "connectivity_state_sa" {
  type        = string
  description = "Connectivity state storage account."
}

variable "connectivity_state_container" {
  type        = string
  description = "Connectivity state container."
  default     = "deploy-container"
}

variable "connectivity_state_key" {
  type        = string
  description = "Connectivity state key."
}

variable "connectivity_state_subscription_id" {
  type        = string
  description = "Optional connectivity remote state subscription id override."
  default     = null
}

variable "management_state_rg" {
  type        = string
  description = "Management state resource group."
}

variable "management_state_sa" {
  type        = string
  description = "Management state storage account."
}

variable "management_state_container" {
  type        = string
  description = "Management state container."
  default     = "deploy-container"
}

variable "management_state_key" {
  type        = string
  description = "Management state key."
}

variable "management_state_subscription_id" {
  type        = string
  description = "Optional management remote state subscription id override."
  default     = null
}
