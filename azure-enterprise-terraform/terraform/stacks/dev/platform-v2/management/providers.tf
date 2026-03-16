provider "azurerm" {
  features {}
  subscription_id            = var.subscription_id
  skip_provider_registration = true
  storage_use_azuread        = true
}

provider "azapi" {}
