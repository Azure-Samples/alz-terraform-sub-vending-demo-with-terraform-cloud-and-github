terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.39.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {

}