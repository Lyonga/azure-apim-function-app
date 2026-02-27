locals {
  suffix = coalesce(var.name_suffix, "001")

  rg_name  = "rg-${var.environment}-${var.project}-platform"
  project_rg_name = "demo-test"
  sa_name  = lower(replace("${var.environment}${var.project}st${local.suffix}", "-", "")) # storage has rules
  acr_name = "acr${var.environment}${var.project}${local.suffix}" # acr has rules
  kv_name  = "kv-${var.environment}-${var.project}-${local.suffix}"
  plocy_audit_vms_name = "audit-vm-manageddisks-${var.environment}-${var.project}"
  Vnet_name = "vnet-${var.environment}-${var.project}"
  analytics_name = "log-${var.environment}-${var.project}"
  common_tags = {
    environment = var.environment
    project     = var.project_name
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
  }
}
