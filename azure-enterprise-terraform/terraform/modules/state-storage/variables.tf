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

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters, lowercase, and alphanumeric."
  }
}

variable "containers" {
  type        = list(string)
  description = "State containers to create."
  default     = ["tfstate"]
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the backend account."
  default     = "GRS"
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version."
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access. Secure baselines should keep this disabled and access state through private connectivity or trusted automation."
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Allow shared key auth. Disable when all users and runners use AAD auth for the backend."
  default     = false
}

variable "enable_network_rules" {
  type        = bool
  description = "Enable network rules on the storage account."
  default     = true
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

variable "queue_logging_retention_days" {
  type        = number
  description = "Queue logging retention in days."
  default     = 10
}

variable "tags" {
  type        = map(string)
  description = "Tags for backend resources."
  default     = {}
}
