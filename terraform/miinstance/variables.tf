variable "mi_rg" {
  type        = string
  description = "Enter SQL MI resource group name"
  default     = "devsqlmirg3"
}

variable "vnetsubnet" {
  type        = string
  description = "Enter vNet subnet name"
  default     = "devsqlmivnetsubnet"
}

variable "vnet_rg" {
  type        = string
  description = "Enter vNet resource group name"
  default     = "devsqlmivnetrg"
}

variable "vnet" {
  type        = string
  description = "Enter vNet name"
  default     = "devsqlmivnet"
}

variable "location" {
  type        = string
  description = "Enter the location where you want to deploy the resources"
  default     = "eastus"
}

variable "miname" {
  type        = string
  description = "Enter managed instance name"
  default     = "devsqlmi3"
}

variable "sku_name" {
  type        = string
  description = "Enter SKU"
  default     = "GP_Gen5"
}

variable "license_type" {
  type        = string
  description = "Enter license type"
  default     = "BasePrice"
}

variable "vcores" {
  type        = number
  description = "Enter number of vCores you want to deploy"
  default     = 4
}

variable "storage_size_in_gb" {
  type        = number
  description = "Enter storage size in GB"
  default     = 32
}

variable "administrator_login" {
  type        = string
  description = "Enter admin login"
  default     = "miadmin"
}

variable "administrator_login_password" {
  type        = string
  description = "Enter admin password"
  default     = "P@ssw0rd1234"
}
