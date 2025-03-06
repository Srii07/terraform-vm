terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.102.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "my-resource-group"
    storage_account_name = "terraformstoragesrinivas"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    access_key = "GGOKtq3HwDU4jAYUb96e4LLEC7p50t9iKaFCf5eDMU1HCdd+l0wkfsX0n9GXAMEuXr7qONJU2cFH+AStpuMj4g=="
  }
}

provider "azurerm" { 
  features {} 
} 

module "resource_group" { 
  source   = "./modules/resource_group" 
  name     = "my-resource-group" 
  location = "East US" 
} 

module "virtual_network" { 
  source              = "./modules/virtual_network" 
  resource_group_name = module.resource_group.name 
  location            = module.resource_group.location 
  vnet_name           = "my-vnet" 
  address_space       = ["10.0.0.0/16"] 
  subnet_name         = "my-subnet" 
  subnet_prefix       = ["10.0.1.0/24"] 
} 

module "public_ip" { 
  source              = "./modules/public_ip" 
  resource_group_name = module.resource_group.name 
  location            = module.resource_group.location 
  public_ip_name      = "my-public-ip" 
} 

module "network_interface" { 
  source                = "./modules/network_interface" 
  resource_group_name   = module.resource_group.name 
  location              = module.resource_group.location 
  subnet_id             = module.virtual_network.subnet_id 
  public_ip_address_id  = module.public_ip.id 
  network_interface_name = "my-nic" 
} 

module "network_security_group" {
  source              = "./modules/network-security-group"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  nsg_name            = "my-nsg"
}

module "storage" {
  source                 = "./modules/storage"
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  storage_account_name   = "terraformstoragesrinivas"
  container_name         = "tfstate"
}

module "virtual_machine" { 
  source                = "./modules/virtual_machine" 
  resource_group_name   = module.resource_group.name 
  location              = module.resource_group.location 
  vm_name               = "my-vm" 
  vm_size               = "Standard_B2s" 
  admin_username        = "srinivas" 
  admin_password        = "pookie@69" 
  network_interface_id  = module.network_interface.id 
}
