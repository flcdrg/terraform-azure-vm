# Deploy a VM to Azure using Terraform

A simple example of using Terraform to deploy a virtual machine in Azure.

This repository is monitored by a [workspace in HCP Cloud](https://app.terraform.io/app/flcdrg/workspaces/terraform-azure-vm/runs) (previously known as Terraform Cloud). Changes that are merged to `main` will be processed, but not applied unless the run is manually approved.

## Assumptions

1. You have a resource group in Azure named `rg-chocotest-australiasoutheast` (referenced in [data-group.tf](data-group.tf))
2. You have configured workspace variables for a service principal so that HCP Cloud can create/update resources in that resource group.
