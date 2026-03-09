variable "name" {
  type        = string
  description = "Action group name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the action group."
}

variable "short_name" {
  type        = string
  description = "Short name for notifications."
}

variable "email_receivers" {
  type        = map(string)
  description = "Email receiver name to address map."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags."
  default     = {}
}
