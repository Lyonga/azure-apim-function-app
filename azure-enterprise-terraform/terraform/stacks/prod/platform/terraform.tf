terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110" 
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.13"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.3"
    }
  }
}

provider "azurerm" { features {} }
provider "azuread" {}
provider "azapi" {}
