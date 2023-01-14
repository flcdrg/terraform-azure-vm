resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-chocotest-australiasoutheast"
  address_space       = ["10.1.0.0/16"]
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-chocotest-australiasoutheast"
  resource_group_name  = data.azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                          = "nic-chocotest-australiasoutheast"
  location                      = data.azurerm_resource_group.group.location
  resource_group_name           = data.azurerm_resource_group.group.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "pip-chocotest-australiasoutheast"
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-chocotest-australiasoutheast"
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "nsgsr-chocotest-australiasoutheast"
  resource_group_name         = data.azurerm_resource_group.group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  description                 = "Allow RDP"
  protocol                    = "Tcp"
  priority                    = 300
  access                      = "Allow"
  direction                   = "Inbound"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = 3389
}


# resource "azurerm_virtual_machine" "vm" {
#   resource_group_name = data.azurerm_resource_group.group.name
#   name = "vm-chocotest-australiasoutheast"
#   boot_diagnostics {
#     enabled = false
#   }

# }