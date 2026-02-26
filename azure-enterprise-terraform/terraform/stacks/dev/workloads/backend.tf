terraform {
  backend "azurerm" {
    resource_group_name  = "demo-vm_group"
    storage_account_name = "demovmgroupa7b5"
    container_name       = "tfstate"
    key                  = "dev-workloads.tfstate"
  }
}
