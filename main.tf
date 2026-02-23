terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Updated to the latest stable version
    }
  }
  backend "azurerm" {
    resource_group_name   = "myResourceGroup"
    storage_account_name  = "chrldemostorageaccount"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# We use variables for repeat settings
variable "location" { default = "West Europe" }
# A name to make sure resources don't clash, we use them in naming  our
# components, as some things (like functions) need a globally unique name
variable "collectionname" { default = "someone-demo-apim" }
variable "adminemail" { default = "c.lyonga03@yahoo.com.com" }
variable "clientemail" { default = "chrlslyonga@gmail.com.com" }
variable "environment" {
  default = "dev"
}
variable "project_name" { default = "demo" }

resource "random_string" "kv_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  key_vault_name = lower("kv-${var.environment}-${var.project_name}-${random_string.kv_suffix.result}")
  key_vault_secret_name = lower("kv-${var.environment}-${var.project_name}-${random_string.kv_suffix.result}")
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.collectionname}"
  location = var.location
}

resource "azurerm_api_management" "demo-charsett" {
  name                = "apim-test-${var.collectionname}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  publisher_name      = "PublisherName"
  publisher_email     = var.adminemail

  sku_name = "Consumption_0"
  identity {
    type = "SystemAssigned"
  }
}

# Our general API definition, here we could include a nice swagger file or something
resource "azurerm_api_management_api" "demo-charsett" {
  name                = "demo-charsett-api"
  resource_group_name = azurerm_resource_group.main.name
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
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.demo-charsett.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.func.default_hostname}/api/"

  # This depends on the existence of the named value, however terraform doesn't know this
  # so we have to define it explicitly
  depends_on          = [azurerm_api_management_named_value.demo-charsett]

  credentials {
      header = {
          x-functions-key = "{{func-functionkey}}"
      }
  }
}

# To store our function code securely (so it isn't easily visible everywhere)
# we store the value as a secret 'named value'
resource "azurerm_api_management_named_value" "demo-charsett" {
  name                = "func-functionkey"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.demo-charsett.name
  display_name        = "func-functionkey"
  value_from_key_vault {
    secret_id = azurerm_key_vault_secret.kv_example.id # Replace with the actual Key Vault secret ID
  }
  secret              = true
}

# We use a policy on our API to set the backend, which has the configuration for the authentication code
resource "azurerm_api_management_api_policy" "demo-charsett" {
  api_name            = azurerm_api_management_api.demo-charsett.name
  api_management_name = azurerm_api_management_api.demo-charsett.api_management_name
  resource_group_name = azurerm_resource_group.main.name

  # Put any policy block here, has to beh XML :(
  # More options: https://docs.microsoft.com/en-us/azure/api-management/api-management-policies
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
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.environment}-${var.project_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # tags                = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "aai-${var.collectionname}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_storage_account" "main" {
  # we use replace to strip out the dashes, as it is not allowed in a storage account name
  name                     = "st${replace(var.collectionname, "-", "")}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "func" {
  name                       = "fa-${var.collectionname}-func"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME         = "python"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.main.instrumentation_key
  }

  site_config {
  }

  provisioner "local-exec" {
    command = <<EOT
      cd func
      zip -r functionapp.zip .
      az functionapp deployment source config-zip \
          --resource-group ${azurerm_resource_group.main.name} \
          --name ${self.name} \
          --src functionapp.zip
    EOT
  }
}

# We use the host key in the APIM to authenticate requests
data "azurerm_function_app_host_keys" "app_function_key" {
  name                = azurerm_linux_function_app.func.name
  resource_group_name = azurerm_resource_group.main.name
}

# Adding Azure tenant ID to the data source for use in the Key Vault resource
# data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv_example" {
  name                        = local.key_vault_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  //enable_rbac_authorization  = true
  # rbac_authorization_enabled = true
}

# resource "azurerm_role_assignment" "pipeline_kv_secrets_officer" {
#   scope                = azurerm_key_vault.kv_example.id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azurerm_client_config.current.object_id
# }
resource "azurerm_key_vault_access_policy" "pipeline" {
  key_vault_id = azurerm_key_vault.kv_example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

resource "azurerm_key_vault_secret" "kv_example" {
  name         = local.key_vault_secret_name
  value        = "kv_example-value" # Replace with the actual secret value
  key_vault_id = azurerm_key_vault.kv_example.id
}

resource "azurerm_key_vault_access_policy" "apim" {
  key_vault_id = azurerm_key_vault.kv_example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_api_management.demo-charsett.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}