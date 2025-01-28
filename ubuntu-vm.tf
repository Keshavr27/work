provider "azurerm" {
  features {}
  subscription_id = "3d6159a1-50b2-4d6c-9480-dba8e0cc6369"
  client_id       = "a2208e91-9545-41a2-9b62-7a3642e54b10"
  client_secret   = "UrH8Q~m3hqjongyNwu.c0kQM5NgOiqwgwMU16cli"
  tenant_id       = "decc8895-ed63-467c-9c63-02d8a7024525"
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP Address
resource "azurerm_public_ip" "example" {
  name                         = "example-pip"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  allocation_method            = "Static"
  idle_timeout_in_minutes      = 4
  sku                          = "Basic"
}

# Network Interface for Ubuntu VM
resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "ubuntu-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.example.id
  }
}

# Virtual Machine (Ubuntu)
resource "azurerm_virtual_machine" "ubuntu_vm" {
  name                  = "ubuntu-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]

  os_profile {
    computer_name  = "ubuntu-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234"  # Ensure you use a secure password or switch to SSH keys
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"  # Ubuntu 20.04 LTS
    version   = "latest"
  }

  storage_os_disk {
    name              = "ubuntu-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = "128"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    environment = "production"
  }
}

# Output the public IP address
output "ubuntu_public_ip" {
  value = azurerm_public_ip.example.ip_address
}

# Output the private IP address
output "ubuntu_private_ip" {
  value = azurerm_network_interface.ubuntu_nic.ip_configuration[0].private_ip_address
}
