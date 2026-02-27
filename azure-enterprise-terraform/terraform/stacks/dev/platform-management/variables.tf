variable "prefix" { type = string, default = "org" }
variable "environment" { type = string, default = "dev" }
variable "location" { type = string, default = "eastus" }
variable "location_short" { type = string, default = "eus" }
variable "tags" { type = map(string), default = {} }
variable "log_analytics_retention_days" { type = number, default = 30 }
