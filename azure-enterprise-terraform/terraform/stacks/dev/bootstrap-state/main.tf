terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" { features {} }

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  name_suffix = random_string.suffix.result
  rg_name     = "rg-tfstate-${var.environment}-${local.name_suffix}"
  sa_name     = substr(lower(replace("sttfstate${var.environment}${local.name_suffix}", "/[^0-9a-z]/", "")), 0, 24)
}

resource "azurerm_resource_group" "state" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "state" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true  # bootstrap simplicity; lock down later
  blob_properties {
    versioning_enabled = true
  }
  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

output "backend_rg_name" { value = azurerm_resource_group.state.name }
output "backend_storage_account_name" { value = azurerm_storage_account.state.name }
output "backend_container_name" { value = azurerm_storage_container.tfstate.name }
