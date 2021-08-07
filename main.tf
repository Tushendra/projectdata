provider "azurerm" {
  features {}

subscription_id = var.subscription_id
client_id       = var.client_id
client_secret   = var.client_secret
tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix     = "10.0.2.0/24"
}

resource "azurerm_public_ip" "main" {
  count               = var.node_count
  name                = "${var.prefix}-${format("%02d", count.index)}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  count               = var.node_count
  name                = "${var.prefix}-${format("%02d", count.index)}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.main.*.id, count.index)
	
  }
}
resource "azurerm_network_security_group" "example_nsg" {
    name = "${var.prefix}-NSG"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    security_rule {
    name = "Inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }  
}    

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.node_count
  name                            = "${var.prefix}-${format("%02d", count.index)}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_Ds1_v2"
  admin_username                  = "tush1"
  admin_password                  = "MishraTush@2021"
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.main.*.id, count.index)]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "${(azurerm_public_ip.main.00.ip_address)}"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
    }

    inline = [
    "touch master_server",
	  "sudo apt-get update",
	  "sudo apt-get install -y openjdk-8-jdk openjdk-8-jre",
    "sudo wget https://get.jenkins.io/war-stable/2.289.2/jenkins.war",
	  
    ]
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "${(azurerm_public_ip.main.01.ip_address)}"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
    }

    inline = [
    "touch build_server",
	  "sudo apt-get update",
	  "sudo apt-get install -y openjdk-8-jdk openjdk-8-jre",
    "sudo apt-get install -y python-pip",
    "sudo apt-get install -y software-properties-common",
    "sudo apt-add-repository ppa:ansible/ansible",
    "sudo apt-get update",
    "sudo apt-get install -y ansible",
    "sudo pip install -y ansible[azure]",
    "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",

    "sudo apt-get install -y docker*",
    "sudo apt-get update",

    "sudo apt install -y git",
	  
    ]
  }
}
