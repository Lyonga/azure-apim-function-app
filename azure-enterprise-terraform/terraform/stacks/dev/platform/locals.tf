locals {
  suffix = coalesce(var.name_suffix, "001")

  rg_name  = "rg-${var.environment}-${var.project}-platform"
  sa_name  = lower(replace("${var.environment}${var.project}st${local.suffix}", "-", "")) # storage has rules
  acr_name = "acr${var.environment}${var.project}${local.suffix}" # acr has rules
  kv_name  = "kv-${var.environment}-${var.project}-${local.suffix}"
  plocy_audit_vms_name = "audit-vm-manageddisks-${var.environment}-${var.project}"
  Vnet_name = "vnet-${var.environment}-${var.project}"
  analytics_name = "log-${var.environment}-${var.project}"
  # acr_name_raw       = "acr-${var.environment}-${var.project}-${random_string.acr.result}"
  # acr_name_sanitized = regexreplace(lower(local.acr_name_raw), "[^0-9a-z]", "")
  # acr_name           = substr(local.acr_name_sanitized, 0, 50)
  common_tags = {
    environment = var.environment
    project     = var.project_name
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
  }
}

# resource "random_string" "acr" {
#   length  = 6
#   upper   = false
#   special = false
# }
