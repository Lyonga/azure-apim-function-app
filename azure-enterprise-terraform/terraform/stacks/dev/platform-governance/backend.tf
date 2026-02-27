terraform {
  backend "azurerm" {
    resource_group_name  = "demo-test"
    storage_account_name = "demotest822e"
    container_name       = "platform-gov-container"
    key                  = "platform_gov.tfstate"
  }
}