data "terraform_remote_state" "global" {
  backend = "azurerm"

  config = {
    resource_group_name  = "myResourceGroup"
    storage_account_name = "chrldemostorageaccount"
    container_name       = "deploy-container"
    key                  = "rg-gov.tfstate"
  }
}