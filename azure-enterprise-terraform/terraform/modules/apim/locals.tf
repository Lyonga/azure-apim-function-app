locals {
  key_vault_name = lower("kv-${var.environment}-${var.project_name}-${random_string.kv_suffix.result}")
  key_vault_secret_name = lower("kv-${var.environment}-${var.project_name}-${random_string.kv_suffix.result}")

  enterprise_tags = {
    environment = var.environment
    project     = var.project_name
    owner       = "Enterprise Team"
  }
}