variable "location" {
  description = "Azure region for all resources"
  default     = "Poland Central"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "sales-rg"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  default     = "salesacr"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  default     = "sales-aks"
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  default     = "sales-pg"
}

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  default     = "adminuser"
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  sensitive   = true
}