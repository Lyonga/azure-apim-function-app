variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "PerGB2018"  # ✅ recommended common value
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "insights_name" {
  type        = string
  default     = "demolo-analytics-insights"
}
