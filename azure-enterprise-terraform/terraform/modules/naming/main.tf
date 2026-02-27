resource "random_string" "suffix" {
  length  = var.suffix_length
  upper   = false
  special = false
}

locals {
  base = "${var.prefix}-${var.service}-${var.environment}-${var.location_short}"
  suf  = random_string.suffix.result
}

output "rg_name" { value = "rg-${local.base}-${local.suf}" }
output "vnet_hub_name" { value = "vnet-hub-${local.base}-${local.suf}" }
output "vnet_spoke_name" { value = "vnet-spoke-${local.base}-${local.suf}" }
output "law_name" { value = "law-${local.base}-${local.suf}" }
output "kv_name" {
  # Key Vault name limits and allowed chars
  value = substr(replace("kv-${local.base}-${local.suf}", "/[^0-9a-zA-Z-]/", ""), 0, 24)
}
output "sa_name" {
  # Storage account name rules: lowercase alphanumeric, 3-24, globally unique
  value = substr(lower(replace("st${var.prefix}${var.service}${var.environment}${var.location_short}${local.suf}", "/[^0-9a-z]/", "")), 0, 24)
}
