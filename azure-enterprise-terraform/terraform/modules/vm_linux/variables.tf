variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }

variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "ssh_public_key" { type = string }

variable "vm_size" { type = string default = "Standard_B2s" }
variable "tags" { type = map(string) default = {} }

variable "os_disk_size_gb" { type = number default = 64 }
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
