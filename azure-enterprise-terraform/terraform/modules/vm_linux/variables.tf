variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "os_disk_size_gb" {
  type    = number
  default = 64
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
}

variable "identity_type" {
  description = "Managed identity mode."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition = contains([
      "None",
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "identity_type must be None, SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "User-assigned identity IDs."
  type        = list(string)
  default     = []
}
