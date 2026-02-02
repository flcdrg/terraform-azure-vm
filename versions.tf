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
      version = "4.58.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

provider "azurerm" {
  features {}
}
