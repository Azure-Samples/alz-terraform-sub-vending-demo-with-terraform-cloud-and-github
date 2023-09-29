data "azuread_client_config" "current" {}


data "azuread_users" "subscription_owners" {
  user_principal_names = var.subscription_owners
}

data "azurerm_management_group" "vending" {
  display_name = var.subscription_management_group
}