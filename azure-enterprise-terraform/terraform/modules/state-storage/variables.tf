variable "create_resource_group" {
  type        = bool
  description = "Create the state resource group."
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "State resource group name."
}

variable "location" {
  type        = string
  description = "Azure region for state resources."
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique state storage account name."
}

variable "containers" {
  type        = list(string)
  description = "State containers to create."
  default     = ["tfstate"]
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the backend account."
  default     = "ZRS"
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version."
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access. GitHub-hosted runners generally require this unless using self-hosted runners."
  default     = true
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Allow shared key auth. Disable when all users and runners use AAD auth for the backend."
  default     = false
}

variable "enable_network_rules" {
  type        = bool
  description = "Enable network rules on the storage account."
  default     = false
}

variable "network_bypass" {
  type        = list(string)
  description = "Azure service bypass rules."
  default     = ["AzureServices"]
}

variable "ip_rules" {
  type        = list(string)
  description = "Optional public IP rules."
  default     = []
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "Optional VNet subnet IDs permitted to the backend."
  default     = []
}

variable "blob_delete_retention_days" {
  type        = number
  description = "Blob soft delete retention."
  default     = 30
}

variable "container_delete_retention_days" {
  type        = number
  description = "Container soft delete retention."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags for backend resources."
  default     = {}
}
