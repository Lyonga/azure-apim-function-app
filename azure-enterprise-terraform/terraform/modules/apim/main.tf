data "azurerm_client_config" "current" {}
resource "azurerm_api_management" "apim" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name

  identity { type = "SystemAssigned" }
  tags = var.tags
}

# API definition via OpenAPI file
resource "azurerm_api_management_api" "api" {
  name                = var.api_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "2"
  display_name        = var.api_display_name
  path                = var.api_path
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file(var.openapi_file)
  }
}

# Host keys
data "azurerm_function_app_host_keys" "host" {
  name                = var.function_app_name
  resource_group_name = var.function_resource_group
}

# Named value holding the function key
resource "azurerm_api_management_named_value" "func_key" {
  name                = var.named_value_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  display_name        = var.named_value_name
  value               = data.azurerm_function_app_host_keys.host.default_function_key
  secret              = true
}

# Backend referencing the function app
resource "azurerm_api_management_backend" "backend" {
  name                = "${var.api_name}-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  protocol            = "http"
  url                 = var.backend_url

  credentials {
    header = {
      x-functions-key = "{{${azurerm_api_management_named_value.func_key.name}}}"
    }
  }

  depends_on = [azurerm_api_management_named_value.func_key]
}

# API policy referencing the backend
resource "azurerm_api_management_api_policy" "policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management_api.api.api_management_name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service backend-id="${azurerm_api_management_backend.backend.name}" />
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
