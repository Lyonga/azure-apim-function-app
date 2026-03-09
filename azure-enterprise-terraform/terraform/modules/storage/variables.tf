variable "name" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account names must be 3-24 characters, lowercase, and alphanumeric."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "GRS"
}

variable "account_kind" {
  type    = string
  default = "StorageV2"
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "allow_blob_public_access" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "shared_access_key_enabled" {
  type    = bool
  default = true
}

variable "infrastructure_encryption_enabled" {
  type    = bool
  default = true
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "change_feed_enabled" {
  type    = bool
  default = true
}

variable "blob_delete_retention_days" {
  type    = number
  default = 30
}

variable "container_delete_retention_days" {
  type    = number
  default = 30
}

variable "queue_logging_retention_days" {
  type    = number
  default = 10
}

variable "enable_network_rules" {
  type    = bool
  default = true
}

variable "network_bypass" {
  type    = list(string)
  default = ["AzureServices"]
}

variable "ip_rules" {
  type    = list(string)
  default = []
}

variable "virtual_network_subnet_ids" {
  type    = list(string)
  default = []
}

variable "containers" {
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
