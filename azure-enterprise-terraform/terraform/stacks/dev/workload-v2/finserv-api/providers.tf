provider "azurerm" {
  features {}
  subscription_id            = var.subscription_id
  skip_provider_registration = true
}

provider "azurerm" {
  alias = "platform"
  features {}
  subscription_id            = coalesce(var.connectivity_state_subscription_id, var.platform_state_subscription_id, var.subscription_id)
  skip_provider_registration = true
  storage_use_azuread        = true
}

provider "azapi" {}
