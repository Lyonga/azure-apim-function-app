variable "location" { default = "West Europe" }
variable "collectionname" { default = "someone-demo-apim" }
variable "adminemail" { default = "c.lyonga03@yahoo.com.com" }
variable "clientemail" { default = "chrlslyonga@gmail.com.com" }
variable "environment" {
  default = "dev"
}
variable "project_name" { default = "demo" }
variable "resource_group_name" {
  type = string
  default = null
}

variable "workload_rg_location" {
  type = string
  default = null
}