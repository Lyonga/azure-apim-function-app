variable "name" {
  type        = string
  description = "Namespace name."
}

variable "resource_group_name" {
  type        = string
  description = "Namespace resource group."
}

variable "location" {
  type        = string
  description = "Namespace location."
}

variable "sku" {
  type        = string
  description = "Namespace SKU."
  default     = "Premium"
}

variable "capacity" {
  type        = number
  description = "Namespace capacity for Premium."
  default     = 1
}

variable "premium_messaging_partitions" {
  type        = number
  description = "Messaging partitions for Premium."
  default     = 1
}

variable "local_auth_enabled" {
  type        = bool
  description = "Allow SAS auth."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public ingress."
  default     = false
}

variable "identity_type" {
  type        = string
  description = "Managed identity type."
  default     = "SystemAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned identity ids."
  default     = []
}

variable "queues" {
  type        = map(any)
  description = "Queues to create."
  default     = {}
}

variable "topics" {
  type        = map(any)
  description = "Topics to create."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
