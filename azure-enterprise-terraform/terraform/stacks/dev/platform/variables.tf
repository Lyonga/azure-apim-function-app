variable "environment" {
  type    = string
  default = "dev"
}
variable "location" {
  description = "The location where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "use_existing_subscription" {
  type    = bool
  default = true
}
variable "subscription_id" {
  type    = string
  default = "ce792f64-9e63-483b-8136-a2538b764f3d"
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "resource_group_name" {
  type    = string
  default = "rg-dev-platform"
}

variable "project_name" {
  type    = string
  default = "azure-enterprise-lab"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "cost_center" {
  type    = string
  default = "cc-0001"
}

# Network
variable "vnet_address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "subnets" {
  type = map(any)
  default = {
    aks = {
      address_prefixes = ["10.10.1.0/24"]
      nsg_rules = []
    }
    app = {
      address_prefixes = ["10.10.2.0/24"]
      nsg_rules = []
    }
  }
}

# AKS
variable "aks_node_pool" {
  type = any
  default = {
    name                = "sys"
    vm_size             = "Standard_D4s_v5"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 128
  }
}

# Storage (general-purpose)
variable "storage_account_name" {
  type    = string
  default = "stdevlab001"
}

# ACR
variable "acr_name" {
  type    = string
  default = "acrdevlab001"
}

# Key Vault
variable "keyvault_name" {
  type    = string
  default = "kv-dev-lab-001"
}

# Optional subscription creation (OFF by default)
variable "enable_subscription_creation" {
  type    = bool
  default = false
}

variable "new_subscription_display_name" {
  type    = string
  default = null
}

variable "billing_scope_id" {
  type    = string
  default = null
}

# Optional Azure DevOps (OFF by default)
variable "enable_azuredevops_repo" {
  type    = bool
  default = false
}

variable "azuredevops_project_name" {
  type    = string
  default = null
}

variable "azuredevops_repo_name" {
  type    = string
  default = null
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
  default     = "ce792f64-9e63-483b-8136-a2538b764f3d"
}

variable "acr_admin_enabled" {
  description = "Flag to enable admin access for Azure Container Registry."
  type        = bool
  default     = false
}

variable "azuredevops_project" {
  description = "The name of the Azure DevOps project."
  type        = string
  default     = "my-azure-devops-project"
}

variable "policy_parameters" {
  description = "Parameters for the policy assignment."
  type        = any
  default     = null
}

variable "policy_definition_id" {
  description = "The ID of the policy definition to assign."
  type        = string
  # default     = null
  default = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
}

variable "policy_scope" {
  description = "The scope for the policy assignment."
  type        = string
  default     = ""
}

variable "azuredevops_default_branch" {
  description = "The default branch for the Azure DevOps repository."
  type        = string
  default     = "main"
}

variable "enable_min_reviewers_policy" {
  description = "Enable the minimum reviewers policy for Azure DevOps."
  type        = bool
  default     = false
}

variable "min_reviewer_count" {
  description = "The minimum number of reviewers required for Azure DevOps."
  type        = number
  default     = 1
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
  default     = "Standard"
}

variable "kv_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
  default     = "standard"
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "storage_account_min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_containers" {
  description = "Map of containers to create in the storage account."
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "allow_blob_public_access" {
  type    = bool
  default = false
}

variable "storage_account_kind" {
  type    = string
  default = "StorageV2"
}