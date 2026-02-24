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
  default     = ""
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
