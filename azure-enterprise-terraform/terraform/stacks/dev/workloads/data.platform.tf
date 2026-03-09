data "terraform_remote_state" "platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = "demo-test"
    storage_account_name = "demotest822e"
    container_name       = "deploy-container"
    key                  = "platform.tfstate" # <-- point to your platform state file
  }
}