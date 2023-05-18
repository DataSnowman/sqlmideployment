variable "vnet_rg" {
  type        = string
  description = "Enter vNet resource group name"
  default     = "devsqlmivnetrg"
}

variable "location" {
  type        = string
  description = "Enter the location where you want to deploy the resources"
  default     = "eastus"
}

variable "vnetsg" {
  type        = string
  description = "Enter vNet security group name"
  default     = "devsqlmivnetsg"
}

variable "vnet" {
  type        = string
  description = "Enter vNet name"
  default     = "devsqlmivnet"
}

variable "vnetaddressspace" {
  type        = list(string)
  description = "Enter vNet address space"
  default     = ["10.0.0.0/24"]
}

variable "vnetsubnet" {
  type        = string
  description = "Enter vNet subnet name"
  default     = "devsqlmivnetsubnet"
}

variable "vnetsubnetaddressprefix" {
  type        = list(string)
  description = "Enter vNet subnet address prefix"
  default     = ["10.0.0.0/25"]
}

variable "vnetrt" {
  type        = string
  description = "Enter vNet route table name"
  default     = "devsqlmivnetrt"
}