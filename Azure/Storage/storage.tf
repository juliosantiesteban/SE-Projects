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
  #checkov:skip=CKV_AZURE_33:Queue service is not used on this account
  #checkov:skip=CKV_AZURE_206:Geo-replication adds cost; LRS is fine for learning
  #checkov:skip=CKV2_AZURE_41:No SAS tokens are issued; access is through Entra ID
  #checkov:skip=CKV2_AZURE_38:Blob soft delete is not needed for this learning account
  #checkov:skip=CKV2_AZURE_1:A customer-managed key adds cost and complexity
  #checkov:skip=CKV2_AZURE_33:A private endpoint would block the hosted runners
  #checkov:skip=CKV2_AZURE_40:Disabling shared keys could break the backend setup; revisit later
  #checkov:skip=CKV_AZURE_59:Network access must stay enabled so the laptop and hosted runners can reach the Terraform state; anonymous blob access is already blocked with allow_nested_items_to_be_public = false
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