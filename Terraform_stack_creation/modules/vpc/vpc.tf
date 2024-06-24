
#1 GET DATA
#data "aws_availibility_zones" "a_zones" {}
data "aws_region" "region" {}

locals {
  common_tags = {
    Owner_1   = "kuba"
    Owner_2   = "bartek"
    VPC       = "vpc_devops_project"
    Terraform = "true"
  } 
}

#2 CREATE VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags       = local.common_tags
}

#3 DEPLOY THE PRIVATE SUBNETS
resource "aws_subnet" "private_subnets" {
    for_each           = var.private_subnets
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = cidrsubnet(var.vpc_cidr, 8, each.value)
    availability_zone  = "eu-north-1a"
    tags = {
        Name      = each.key
        Terraform = "true"
    }
}
#4 DEPLOY THE PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
    for_each           = var.public_subnets
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
    availability_zone  = "eu-north-1a"
    tags = {
        Name      = each.key
        Terraform = "true"
    }
}

#5 CREATE ROUTE TABLES FOR PUBLIC AND PRIVATE SUBNETS
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    
    }
    tags = {
        Name      = "public_rtb"
        Terraform = "true"
    }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "private_rtb"
    Terraform = "true"
  }
}

#6 CREATE ROUTE TABLE ASSOCIATIONS
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#7 CEATE IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

#8 CREATE EIP FOR NAT
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_igw_eip"
  }
}

#9 CREATE NAT GW
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "demo_nat_gateway"
  }
}

