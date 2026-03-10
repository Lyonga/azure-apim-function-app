data "terraform_remote_state" "global" {
  count   = var.use_global_remote_state ? 1 : 0
  backend = "azurerm"

  config = {
    resource_group_name  = var.global_state_rg
    storage_account_name = var.global_state_sa
    container_name       = var.global_state_container
    key                  = var.global_state_key
  }
}
