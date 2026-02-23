variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "public_ip_id" { type = string }
variable "frontend_name" {
  type    = string
  default = "fe"
}
variable "backend_pool_name" { type = string default = "be" }
variable "tags" { type = map(string) default = {} }
