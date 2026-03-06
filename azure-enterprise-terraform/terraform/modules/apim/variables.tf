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

variable "name"                { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "publisher_name"      { type = string }
variable "publisher_email"     { type = string }
variable "sku_name"            { 
  type = string  
  default = "Consumption_0" 
  }
variable "tags"                { 
  type = map(string) 
  default = {} 
  }

# API import
variable "api_name"            { type = string }
variable "api_display_name"    { type = string }
variable "api_path"            { type = string }
variable "openapi_file"        { type = string }

# Backend
variable "backend_url"         { type = string }
variable "named_value_name"    { type = string }

# Function App identity
variable "function_app_name"       { type = string }
variable "function_resource_group" { type = string }