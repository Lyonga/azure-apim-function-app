# Enterprise backend (Azure Storage).
# NOTE: Terraform does not allow variables in backend blocks. Fill these in after bootstrap.
terraform {
  backend "azurerm" {
    resource_group_name  = "demo-test"
    storage_account_name = "demotest822e"
    container_name       = "deploy-container"
    key                  = "platform.tfstate"
  }
}
