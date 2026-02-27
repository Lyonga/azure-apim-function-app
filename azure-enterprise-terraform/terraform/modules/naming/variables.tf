variable "prefix" { type = string }
variable "environment" { type = string }
variable "service" { type = string }
variable "location_short" {
  type        = string
  description = "Short code for naming, e.g. eus, cus."
}
variable "suffix_length" {
  type    = number
  default = 4
}
