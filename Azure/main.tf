terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {
    resource_group_name  = "rg-seportfolio"
    storage_account_name = "seportfolio"
    container_name       = "tfstate"
    key                  = "azure/dev.tfstate"
    use_azuread_auth     = true
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

resource "azurerm_key_vault" "main" {
  name                       = "kv-${module.naming.prefix}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = module.naming.tags
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "key_vault_name" { value = azurerm_key_vault.main.name }
output "name_prefix" { value = module.naming.prefix }

