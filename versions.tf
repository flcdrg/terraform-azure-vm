terraform {
  required_version = ">= 1.13.5"
  cloud {
    organization = "flcdrg"
    hostname     = "app.terraform.io"

    workspaces {
      name = "terraform-azure-vm"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.79.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "azurerm" {
  features {}
}
