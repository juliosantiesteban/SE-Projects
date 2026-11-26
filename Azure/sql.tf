variable "sql_admin_login" {
  type      = string
  sensitive = true
}

variable "sql_admin_object_id" {
  type      = string
  sensitive = true
}

variable "client_ip" {
  type      = string
  sensitive = true
}

variable "sql_location" {
  type    = string
  default = "centralus"
}

locals {
  sql_suffix = substr(replace(data.azurerm_client_config.current.subscription_id, "-", ""), 0, 6)
}

resource "azurerm_mssql_server" "main" {
  #checkov:skip=CKV_AZURE_113:Public endpoint is needed from the laptop and CI; the firewall allows one IP and sign-in is Entra-only
  #checkov:skip=CKV2_AZURE_45:A private endpoint costs money and would block the laptop
  #checkov:skip=CKV_AZURE_23:Server auditing needs paid storage or Log Analytics; audit trail comes with Project 4
  #checkov:skip=CKV_AZURE_24:Same reason as CKV_AZURE_23
  #checkov:skip=CKV2_AZURE_2:Vulnerability assessment needs Defender for SQL, a paid add-on
  name                = "sql-sepf-dev-cus-${local.sql_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.sql_location
  version             = "12.0"
  minimum_tls_version = "1.2"
  tags                = module.naming.tags

  azuread_administrator {
    login_username              = var.sql_admin_login
    object_id                   = var.sql_admin_object_id
    azuread_authentication_only = true
  }
}

resource "azapi_resource" "sql_database" {
  type      = "Microsoft.Sql/servers/databases@2023-08-01-preview"
  name      = "sqldb-${module.naming.prefix}"
  parent_id = azurerm_mssql_server.main.id
  location  = var.sql_location
  tags      = module.naming.tags

  body = {
    sku = {
      name     = "GP_S_Gen5"
      tier     = "GeneralPurpose"
      family   = "Gen5"
      capacity = 2
    }
    properties = {

      maxSizeBytes                     = 34359738368
      requestedBackupStorageRedundancy = "Local"
      useFreeLimit                     = true
      freeLimitExhaustionBehavior      = "AutoPause"
      zoneRedundant                    = false
    }
  }
}

resource "azurerm_mssql_firewall_rule" "client" {
  name             = "laptop"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azapi_resource.sql_database.name
}