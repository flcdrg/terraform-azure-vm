resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-chocotest-australiasoutheast"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}



# resource "azurerm_virtual_machine" "vm" {
#   resource_group_name = data.azurerm_resource_group.group.name
#   name = "vm-chocotest-australiasoutheast"
#   boot_diagnostics {
#     enabled = false
#   }

# }