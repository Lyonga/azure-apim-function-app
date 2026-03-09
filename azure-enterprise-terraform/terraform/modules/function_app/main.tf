resource "azurerm_service_plan" "this" {
  name                   = "${var.name}-plan"
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = "Linux"
  sku_name               = var.app_service_plan_sku
  worker_count           = 2
  zone_balancing_enabled = true
  tags                   = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.this.id
  storage_account_name          = var.storage_account_name
  storage_account_access_key    = var.storage_account_access_key
  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.virtual_network_subnet_id
  functions_extension_version   = var.functions_extension_version
  app_settings                  = var.app_settings
  tags                          = var.tags

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  site_config {
    always_on                              = var.always_on
    ftps_state                             = var.ftps_state
    minimum_tls_version                    = "1.2"
    scm_minimum_tls_version                = "1.2"
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    health_check_path                      = var.health_check_path
    application_insights_connection_string = var.application_insights_connection_string

    application_stack {
      python_version = var.runtime == "python" ? var.runtime_version : null
    }
  }
}
