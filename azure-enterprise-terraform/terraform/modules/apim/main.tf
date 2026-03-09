resource "azurerm_api_management" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  publisher_name                = var.publisher_name
  publisher_email               = var.publisher_email
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_type          = var.virtual_network_type
  tags                          = var.tags

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "virtual_network_configuration" {
    for_each = var.subnet_id == null ? [] : [1]
    content {
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_api_management_api" "this" {
  count               = var.api_name == null ? 0 : 1
  name                = var.api_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  revision            = var.api_revision
  display_name        = var.api_display_name
  path                = var.api_path
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file(abspath(var.api_spec_path))
  }
}

data "azurerm_function_app_host_keys" "host" {
  count               = var.function_app_name == null ? 0 : 1
  name                = var.function_app_name
  resource_group_name = var.function_resource_group
}

resource "azurerm_api_management_named_value" "function_key" {
  count               = var.function_app_name == null ? 0 : 1
  name                = var.named_value_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  display_name        = var.named_value_name
  value               = data.azurerm_function_app_host_keys.host[0].default_function_key
  secret              = true
}

resource "azurerm_api_management_backend" "this" {
  count               = var.function_app_name == null ? 0 : 1
  name                = "${var.api_name}-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  protocol            = "http"
  url                 = var.function_app_name == null ? var.backend_url : "https://${var.function_app_name}.azurewebsites.net/api/"

  credentials {
    header = {
      x-functions-key = "{{${azurerm_api_management_named_value.function_key[0].name}}}"
    }
  }
}

resource "azurerm_api_management_api_policy" "this" {
  count               = var.function_app_name == null ? 0 : 1
  api_name            = azurerm_api_management_api.this[0].name
  api_management_name = azurerm_api_management_api.this[0].api_management_name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service backend-id="${azurerm_api_management_backend.this[0].name}" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
