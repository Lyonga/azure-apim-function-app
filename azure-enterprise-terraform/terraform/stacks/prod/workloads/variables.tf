variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "eastus2"
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

variable "platform_state_rg" {
  type    = string
  default = "rg-tfstate-prod"
}

variable "platform_state_sa" {
  type    = string
  default = "sttfstateprod001"
}

variable "platform_state_container" {
  type    = string
  default = "tfstate"
}

variable "platform_state_key" {
  type    = string
  default = "prod.platform.tfstate"
}

variable "create_demo_vm" {
  type    = bool
  default = false
}

variable "vm_name" {
  type    = string
  default = "vm-prod-demo-01"
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa REPLACE_ME"
}

variable "vm_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
