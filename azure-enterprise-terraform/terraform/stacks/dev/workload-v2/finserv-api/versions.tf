terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}
