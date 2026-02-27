terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
  }
}

# provider "azurerm" { 
#   alias           = "sub"
#   subscription_id = var.subscription_id
#   tenant_id       = var.tenant_id
#   features {} 
#   }