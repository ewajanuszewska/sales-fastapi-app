terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
  }
}

provider "azurerm" {
  subscription_id = "38a8d341-0d41-4704-96f8-f75bf8fd7e8c"
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "salesaks"

  default_node_pool {
    name       = "nodepool1"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

  depends_on = [azurerm_container_registry.acr]
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                         = var.postgres_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "13"

  sku_name = "B_Standard_B1ms"
  administrator_login          = var.postgres_admin_user
  administrator_password       = var.postgres_admin_password

  backup_retention_days        = 7
  zone                         = "1"
  storage_mb                   = 32768

  authentication {
    password_auth_enabled = true
  }
}

resource "azurerm_postgresql_flexible_server_database" "salesdb" {
  name                = "salesdb"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset             = "UTF8"
  collation           = "en_US.utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}