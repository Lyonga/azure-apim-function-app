locals {
  //rg_name   = data.terraform_remote_state.platform.outputs.resource_group_name
  rg_name  = data.terraform_remote_state.global.outputs.workload_rg_name
  subnet_ids = data.terraform_remote_state.platform.outputs.subnet_ids
  workload_rg_location = data.terraform_remote_state.global.outputs.workload_rg_location
}

# Demo VM (in app subnet)
module "vm" {
  count               = var.create_demo_vm ? 1 : 0
  source              = "../../../modules/vm_linux"
  name                = var.vm_name
  resource_group_name = local.rg_name
  image               = var.vm_image
  //source_image       = var.source_image
  location            = data.terraform_remote_state.global.outputs.workload_rg_location
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  os_disk_size_gb     = var.os_disk_size_gb
  subnet_id           = local.subnet_ids["app"]
  ssh_public_key      = var.ssh_public_key
  tags                = local.tags_common
}

module "pip" {
  count               = var.create_demo_lb ? 1 : 0
  source              = "../../../modules/public_ip"
  name                = "pip-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  allocation_method   = var.allocation_method
  sku                 = var.sku
  location            = data.terraform_remote_state.global.outputs.workload_rg_location
  tags                = local.tags_common
}

module "lb" {
  count               = var.create_demo_lb ? 1 : 0
  source              = "../../../modules/load_balancer"
  name                = "lb-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = data.terraform_remote_state.global.outputs.workload_rg_location
  backend_pool_name   = var.backend_pool_name
  frontend_name       = var.frontend_name
  public_ip_id        = module.pip[0].id
  tags                = local.tags_common
}

# Log Analytics
# Random suffix for KV
resource "random_string" "kv_suffix" {
  length  = 6
  upper   = false
  special = false
}

# ───────────────────────────────────────────────────────────────────────────────
# Observability: LAW + App Insights
module "observability" {
  source              = "../../../modules/observability"
  name =               "law-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = local.workload_rg_location
  insights_name       = "appi-${var.environment}-${var.project_name}"
  retention_in_days   = var.retention_in_days
  sku                 = var.analytics_sku
  tags                = local.tags_common
}


# Function App
module "function_app" {
  source = "../../../modules/function_app"

  name                       = "fa-${local.name_prefix}-func"
  resource_group_name        = data.terraform_remote_state.global.outputs.workload_rg_name
  location                   = data.terraform_remote_state.global.outputs.workload_rg_location
  runtime               = "python"
  runtime_version       = "3.11"
  #service_plan_sku      = "Y1"

  storage_account_name       = module.storage_account.name
  storage_account_access_key = module.storage_account.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "python"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = module.observability.appi_instrumentation_key
  }

  tags = local.tags_common
}

# Key Vault (Access Policy or RBAC based on toggle)
# resource "random_string" "kv_suffix" {
#   length  = 5
#   upper   = false
#   special = false
# }

module "keyvault" {
  source = "../../../modules/keyvault"

  name                        = lower("kv-${local.env}-${local.project}-${random_string.kv_suffix.result}")
  location                    = data.terraform_remote_state.global.outputs.workload_rg_location
  resource_group_name         = data.terraform_remote_state.global.outputs.workload_rg_name
  sku_name                    = "standard"
  enable_rbac_authorization   = var.kv_enable_rbac
  purge_protection_enabled    = true
  soft_delete_retention_days  = 30
  tags                        = local.tags_common
}

# If not using RBAC, grant deployer access so we can set secrets
resource "azurerm_key_vault_access_policy" "deployer" {
  count        = var.kv_enable_rbac ? 0 : 1
  key_vault_id = module.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
}
resource "time_sleep" "kv_policy_propagation" {
  count           = var.kv_enable_rbac ? 0 : 1
  depends_on      = [azurerm_key_vault_access_policy.deployer]
  create_duration = "30s"
}

resource "azurerm_key_vault_secret" "hello" {
  count        = var.kv_enable_rbac ? 0 : 1
  name         = "hello-secret"
  value        = "world"
  key_vault_id = module.keyvault.id

  depends_on = [time_sleep.kv_policy_propagation]
}

# APIM
# module "apim" {
#   source = "../.../../modules/apim" 
#   name                = "apim-test-${local.name_prefix}"
#   resource_group_name = data.terraform_remote_state.global.outputs.workload_rg_name
#   location            = data.terraform_remote_state.global.outputs.workload_rg_location
#   sku_name            = "Consumption_0"
#   publisher_name  = var.publisher_name
#   publisher_email = var.publisher_email
#   api_name             = "demo-charsett-api"
#   api_display_name     = "demo-charsett API"
#   api_path             = "demo-charsett"
#   openapi_file         = "api-spec.yml"

#   backend_url          = "https://${module.function_app.default_hostname}/api/"
#   named_value_name     = "func-functionkey"
#   named_value_secret   = null
#   tags = local.tags_common
# }