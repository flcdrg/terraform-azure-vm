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

resource "azurerm_network_interface_security_group_association" "nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
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
  connection {
  }
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

resource "random_password" "password" {
  length      = 16
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine.html
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "vm-chocotest-australiasoutheast"
  resource_group_name   = data.azurerm_resource_group.group.name
  location              = data.azurerm_resource_group.group.location
  size                  = "Standard_D4s_v3"
  admin_username        = "david1" # Can't use 'David' because who knows why!
  admin_password        = random_password.password.result
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  source_image_reference {
    # publisher = "microsoftwindowsdesktop"
    # sku       = "win11-22h2-pro"
    # offer     = "windows-11"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    offer     = "WindowsServer"
    version   = "latest"
  }
  computer_name            = "vm-chocotest"
  enable_automatic_updates = true
  hotpatching_enabled      = false
  license_type             = "Windows_Server" # Windows_Client
}

resource "azurerm_virtual_machine_extension" "vm-extension" {
  name                       = "windows-vm-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    { 
      "commandToExecute": "powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); choco feature enable -n allowGlobalConfirmation"
    } 
  SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  location              = data.azurerm_resource_group.group.location
  virtual_machine_id    = azurerm_windows_virtual_machine.vm.id
  timezone              = "UTC"
  daily_recurrence_time = "1000"
  notification_settings {
    enabled         = true
    time_in_minutes = 30
    email           = "david@gardiner.net.au"
  }
}

output "password" {
  description = "admin password"
  value       = random_password.password.result
  sensitive   = true
}
