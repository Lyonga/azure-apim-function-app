

data "azurerm_client_config" "current" {}

resource "azurerm_api_management" "demo-charsett" {
  name                = "apim-test-${var.collectionname}"
  resource_group_name = var.resource_group_name
  location            = var.workload_rg_location
  publisher_name      = "PublisherName"
  publisher_email     = var.adminemail

  sku_name = "Consumption_0"
  identity {
    type = "SystemAssigned"
  }
  tags = local.enterprise_tags
}

# Our general API definition, here we could include a nice swagger file or something
resource "azurerm_api_management_api" "demo-charsett" {
  name                = "demo-charsett-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.demo-charsett.name
  revision            = "2"
  display_name        = "demo-charsett API"
  path                = "demo-charsett"
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("api-spec.yml")
  }
}

# A seperate backend definition, we need this to set our authorisation code for our azure function
resource "azurerm_api_management_backend" "demo-charsett" {
  name                = "demo-charsett-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.demo-charsett.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.func.default_hostname}/api/"
  depends_on          = [azurerm_api_management_named_value.demo-charsett]

  credentials {
      header = {
          x-functions-key = "{{func-functionkey}}"
      }
  }
}

resource "azurerm_api_management_named_value" "demo-charsett" {
  name                = "func-functionkey"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.demo-charsett.name
  display_name        = "func-functionkey"
  value  = data.azurerm_function_app_host_keys.app_function_key.default_function_key
  secret              = true
  depends_on = [ azurerm_key_vault.kv_example ]
}

# We use a policy on our API to set the backend, which has the configuration for the authentication code
resource "azurerm_api_management_api_policy" "demo-charsett" {
  api_name            = azurerm_api_management_api.demo-charsett.name
  api_management_name = azurerm_api_management_api.demo-charsett.api_management_name
  resource_group_name = var.resource_group_name
  xml_content = <<XML
    <policies>
        <inbound>
            <base />
            <set-backend-service backend-id="${azurerm_api_management_backend.demo-charsett.name}" />
        </inbound>
    </policies>
  XML
}

# Below just a generic app service plan and python function setup
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.collectionname}"
  resource_group_name = var.resource_group_name
  location            = var.workload_rg_location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.environment}-${var.project_name}"
  location            = var.workload_rg_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # tags                = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "aai-${var.collectionname}"
  resource_group_name = var.resource_group_name
  location            = var.workload_rg_location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags = local.enterprise_tags
}

resource "null_resource" "deploy_function_app" {
  provisioner "local-exec" {
    command = <<EOT
      cd func
      zip -r functionapp.zip .
      az functionapp deployment source config-zip \
        --resource-group ${azurerm_resource_group.main.name} \
        --name ${azurerm_linux_function_app.func.name} \
        --src functionapp.zip
    EOT
  }

  depends_on = [azurerm_linux_function_app.func]
}

# We use the host key in the APIM to authenticate requests
# data "azurerm_function_app_host_keys" "app_function_key" {
#   name                = azurerm_linux_function_app.func.name
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_key_vault_access_policy" "pipeline" {
#   key_vault_id = azurerm_key_vault.kv_example.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id
#   //object_id    = azurerm_api_management.demo-charsett.identity[0].principal_id

#   secret_permissions = [
#     "Get", "List", "Set", "Delete", "Purge", "Recover"
#   ]
# }

# resource "time_sleep" "kv_policy_propagation" {
#   depends_on      = [azurerm_key_vault_access_policy.pipeline]
#   create_duration = "30s"
# }
