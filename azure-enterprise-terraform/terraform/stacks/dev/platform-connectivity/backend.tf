terraform {
  backend "azurerm" {
    resource_group_name  = "demo-test"
    storage_account_name = "demotest822e"
    container_name       = "platform-container"
    key                  = "platform.tfstate"
  }
}