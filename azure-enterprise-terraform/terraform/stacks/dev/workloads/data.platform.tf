data "terraform_remote_state" "platform" {
  count   = var.use_platform_remote_state ? 1 : 0
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_rg
    storage_account_name = var.platform_state_sa
    container_name       = var.platform_state_container
    key                  = var.platform_state_key
  }
}
