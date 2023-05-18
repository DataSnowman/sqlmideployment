# TODO set the variables below either enter them in plain text after = sign, or change them in variables.tf
#  (var.xyz will take the default value from variables.tf if you don't change it)

# Create resource group
resource "azurerm_resource_group" "example" {
  name     = var.vnet_rg
  location = var.location
}

# Create security group
resource "azurerm_network_security_group" "example" {
  name                = var.vnetsg
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = var.vnet
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.vnetaddressspace
  location            = azurerm_resource_group.example.location
}

# Create a subnet
resource "azurerm_subnet" "example" {
  name                 = var.vnetsubnet
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.vnetsubnetaddressprefix

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Associate subnet and the security group
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Create a route table
resource "azurerm_route_table" "example" {
  name                          = var.vnetrt
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = false
}

# Associate subnet and the route table
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id         = azurerm_subnet.example.id
  route_table_id    = azurerm_route_table.example.id
}