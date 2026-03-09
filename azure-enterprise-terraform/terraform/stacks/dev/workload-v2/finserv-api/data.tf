data "azurerm_client_config" "current" {}

data "terraform_remote_state" "connectivity" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.connectivity_state_rg
    storage_account_name = var.connectivity_state_sa
    container_name       = var.connectivity_state_container
    key                  = var.connectivity_state_key
  }
}

data "terraform_remote_state" "management" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.management_state_rg
    storage_account_name = var.management_state_sa
    container_name       = var.management_state_container
    key                  = var.management_state_key
  }
}
