variable "environment" {
  type        = string
  description = "Environment tag."
}

variable "subscription_id" {
  type        = string
  description = "Connectivity subscription id."
}

variable "subscription_catalog_entry_key" {
  type        = string
  description = "Entry key in the subscriptions catalog for this stack."
  default     = "connectivity"
}

variable "use_subscriptions_state" {
  type        = bool
  description = "Validate the stack subscription against the central subscriptions state."
  default     = true
}

variable "subscriptions_state_rg" {
  type        = string
  description = "Resource group hosting the subscriptions stack state."
  default     = "rg-tfstate-dev"
}

variable "subscriptions_state_sa" {
  type        = string
  description = "Storage account hosting the subscriptions stack state."
  default     = "demotest822e"
}

variable "subscriptions_state_container" {
  type        = string
  description = "Container hosting the subscriptions stack state."
  default     = "deploy-container"
}

variable "subscriptions_state_key" {
  type        = string
  description = "State blob key for the subscriptions stack."
  default     = "global/subscriptions.tfstate"
}

variable "subscriptions_state_subscription_id" {
  type        = string
  description = "Subscription containing the subscriptions stack remote state."
  default     = null
}

variable "application" {
  type        = string
  description = "Application code."
  default     = "connectivity"
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
  description = "Connectivity resource group name."
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub VNet name."
}

variable "hub_address_space" {
  type        = list(string)
  description = "Hub VNet CIDR ranges."
}

variable "enable_firewall" {
  type        = bool
  description = "Deploy Azure Firewall into the hub."
  default     = false
}

variable "dns_servers" {
  type        = list(string)
  description = "Optional custom DNS servers."
  default     = null
}

variable "private_dns_zones" {
  type = map(object({
    name = string
  }))
  description = "Private DNS zones to create in the hub."
  default = {
    keyvault   = { name = "privatelink.vaultcore.azure.net" }
    blob       = { name = "privatelink.blob.core.windows.net" }
    queue      = { name = "privatelink.queue.core.windows.net" }
    table      = { name = "privatelink.table.core.windows.net" }
    file       = { name = "privatelink.file.core.windows.net" }
    websites   = { name = "privatelink.azurewebsites.net" }
    sql        = { name = "privatelink.database.windows.net" }
    servicebus = { name = "privatelink.servicebus.windows.net" }
    appconfig  = { name = "privatelink.azconfig.io" }
  }
}

variable "business_owner" {
  type        = string
  description = "Business owner tag."
  default     = "network"
}

variable "source_repo" {
  type        = string
  description = "Source repository tag."
  default     = "azure-apim-function-app"
}

variable "terraform_workspace" {
  type        = string
  description = "Terraform workspace or stack name."
  default     = "platform-connectivity"
}

variable "recovery_tier" {
  type        = string
  description = "Recovery method tag."
  default     = "terraform"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
  default     = "shared-network"
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
