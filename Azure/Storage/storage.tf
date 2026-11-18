terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "5fbd4a0b-a5d3-4ed3-9ae8-b3d93d94c73c"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-seportfolio"
  location = "eastus"
}

resource "azurerm_storage_account" "sa" {
  name                            = "seportfolio"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}