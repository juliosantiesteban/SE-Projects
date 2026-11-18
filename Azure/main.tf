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

data "azurerm_client_config" "current" {}

output "hello_azure" {
  value = "Hello from Azure tenant ${data.azurerm_client_config.current.tenant_id}"
}

module "naming" {
  source      = "../Shared/naming"
  project     = "sepf"
  environment = "dev"
  owner       = "julio"
  location    = "eus"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${module.naming.prefix}"
  location = "eastus"
  tags     = module.naming.tags
}