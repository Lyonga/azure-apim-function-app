variable "environment" {
  type    = string
  default = "dev"
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "project_name" {
  type    = string
  default = "azure-enterprise-lab"
}
variable "owner" {
  type    = string
  default = "app-team"
}
variable "cost_center" {
  type    = string
  default = "cc-0001"
}

# Reference platform remote state
variable "platform_state_rg" {
  type    = string
  default = "rg-tfstate-dev"
}
variable "platform_state_sa" {
  type    = string
  default = "sttfstatedev001"
}
variable "platform_state_container" {
  type    = string
  default = "tfstate"
}
variable "platform_state_key" {
  type    = string
  default = "dev.platform.tfstate"
}

# Workload VM
variable "create_demo_vm" {
  type    = bool
  default = true
}
variable "vm_name" {
  type    = string
  default = "vm-dev-demo-01"
}
variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa REPLACE_ME"
}
variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}
variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
  default     = "azureuser"
}
variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB."
  type        = number
  default     = 30
}

# Public LB demo
variable "create_demo_lb" {
  type    = bool
  default = true
}
variable "allocation_method" {
  description = "The allocation method for the public IP."
  type        = string
  default     = "Dynamic"
}
variable "sku" {
  description = "The SKU of the public IP."
  type        = string
  default     = "Basic"
}
variable "backend_pool_name" {
  description = "The name of the backend pool for the load balancer."
  type        = string
  default     = "backend-pool"
}
variable "frontend_name" {
  description = "The name of the frontend configuration for the load balancer."
  type        = string
  default     = "frontend-config"
}

variable "vm_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
}

variable "storage_account_name" {
  type    = string
  default = "stdefaultcollection001"
}

variable "retention_in_days" {
  description = "The retention period for the Log Analytics workspace in days."
  type        = number
  default     = 30
}

variable "analytics_sku" {
  description = "The SKU of the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "service_plan_sku" { default = "Y1" }
variable "runtime" { default = "python" }
variable "runtime_version" { default = "3.11" }
variable "collection_name" { default = "default-collection" }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "kv_enable_rbac" {
  type    = bool
  default = false
}

variable "publisher_name" { default = "project-demo-apim" }
variable "publisher_email" { default = "c.lyonga03@yahoo.com.com" }
