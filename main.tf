terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "clenka_portf_tera_rg" {
  name     = "clenka_portf_tera_rg"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}


resource "azurerm_network_security_group" "clenka_portf_tera_secgrp" {
  name                = "clenka_portf_tera_secgrp"
  location            = azurerm_resource_group.clenka_portf_tera_rg.location
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name
}

resource "azurerm_virtual_network" "clenka_portf_tera_vnet" {
  name                = "clenka_portf_tera_vnet"
  location            = azurerm_resource_group.clenka_portf_tera_rg.location
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "clenka_portf_tera_snet" {
  name                 = "clenka_portf_tera_snet"
  resource_group_name  = azurerm_resource_group.clenka_portf_tera_rg.name
  virtual_network_name = azurerm_virtual_network.clenka_portf_tera_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

resource "azurerm_network_security_rule" "clenka_portf_tera_sgr_rule" {
  name                        = "clenka_portf_tera_sgr_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.clenka_portf_tera_rg.name
  network_security_group_name = azurerm_network_security_group.clenka_portf_tera_secgrp.name
}

resource "azurerm_subnet_network_security_group_association" "clenka_portf_tera_sgr_rule_assoc" {
  subnet_id                 = azurerm_subnet.clenka_portf_tera_snet.id
  network_security_group_id = azurerm_network_security_group.clenka_portf_tera_secgrp.id
}

# Dynamic Ip 
resource "azurerm_public_ip" "clenka_portf_tera_dyn_ip" {
  name                = "clenka_portf_tera_dyn_ip"
  location            = azurerm_resource_group.clenka_portf_tera_rg.location
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

# Network interface
resource "azurerm_network_interface" "clenka_portf_tera_nic" {
  name                = "clenka_portf_tera_nic"
  location            = azurerm_resource_group.clenka_portf_tera_rg.location
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.clenka_portf_tera_snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.clenka_portf_tera_dyn_ip.id
  }

  tags = {
    environment = "dev"
  }
}

# Create VM
resource "azurerm_linux_virtual_machine" "clenka_portf_tera_vm" {
  name                = "clenka-vm"
  location            = azurerm_resource_group.clenka_portf_tera_rg.location
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.clenka_portf_tera_nic.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/clenka_portf_terraform.key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/clenka_portf_terraform.key"
    })

    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}

// We could get it not from here but azure
data "azurerm_public_ip" "clenka_portf_tera_dyn_ip_data" {
  name                = azurerm_public_ip.clenka_portf_tera_dyn_ip.name
  resource_group_name = azurerm_resource_group.clenka_portf_tera_rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.clenka_portf_tera_vm.name}: ${data.azurerm_public_ip.clenka_portf_tera_dyn_ip_data.ip_address}"
}