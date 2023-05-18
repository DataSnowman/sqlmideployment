# TODO set the variables below either enter them in plain text after = sign, or change them in variables.tf
#  (var.xyz will take the default value from variables.tf if you don't change it)

# Create resource group

resource "azurerm_resource_group" "example" {
  name     = var.mi_rg
  location = var.location
}

data "azurerm_subnet" "example" {
  name                 = var.vnetsubnet
  resource_group_name  = var.vnet_rg
  virtual_network_name = var.vnet

  depends_on = [
    azurerm_resource_group.example
  ]
}

output "subnet_id" {
  value = data.azurerm_subnet.example.id
}

# Create managed instance
resource "azurerm_mssql_managed_instance" "main" {
  name                         = var.miname
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  subnet_id                    = data.azurerm_subnet.example.id
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  license_type                 = var.license_type
  sku_name                     = var.sku_name
  vcores                       = var.vcores
  storage_size_in_gb           = var.storage_size_in_gb
}