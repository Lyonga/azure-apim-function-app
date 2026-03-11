provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuredevops" {
  org_service_url       = var.enable_azuredevops ? var.azuredevops_org_service_url : "https://dev.azure.com/disabled"
  personal_access_token = var.enable_azuredevops ? var.azuredevops_personal_access_token : "disabled"
}
