provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {
  features {}
}

resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "My Transit Gateway"
  tags = {
    Name = "My Transit Gateway"
  }
}

resource "azurerm_virtual_wan" "virtual_wan" {
  name                = "My Virtual WAN"
  resource_group_name = "My Resource Group"
  location            = "West US 2"
}

resource "aws_ec2_transit_gateway_vpn_attachment" "vpn_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpn_connection_id  = var.aws_vpn_connection_id
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "My VPN Gateway"
  location            = "West US 2"
  resource_group_name = "My Resource Group"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku {
    name     = "VpnGw1"
    tier     = "VpnGw1"
    capacity = 2
  }
}

resource "azurerm_virtual_network_gateway_connection" "vpn_connection" {
  name                = "My VPN Connection"
  location            = "West US 2"
  resource_group_name = "My Resource Group"
  virtual_network_gateway_id     = azurerm_virtual_network_gateway.vpn_gateway.id
  remote_virtual_network_address_space = ["10.0.0.0/16"]
  connection_protocol                 = "IKEv2"
  shared_key                           = "MySharedKey"
}

resource "azurerm_virtual_network_gateway_connection_shared_key" "vpn_shared_key" {
  name                = "My VPN Shared Key"
  resource_group_name = "My Resource Group"
  virtual_network_gateway_connection_id = azurerm_virtual_network_gateway_connection.vpn_connection.id
  value               = "MySharedKey"
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpn_attachment.vpn_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
  resource_id = azurerm_virtual_network_gateway.vpn_gateway.ip_configuration[0].public_ip_address
}

variable "aws_vpn_connection_id" {
  description = "The ID of the AWS VPN connection"
}

