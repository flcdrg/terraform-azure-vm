terraform {
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
      version = "4.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}
