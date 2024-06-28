data "aws_region" "region" {}

locals {
  common_tags = {
    Name      = "Kubernetes_Project_VPC_Terraform"
    Owner_1   = "kuba"
    Owner_2   = "bartek"
    VPC       = "vpc_devops_project"
    Terraform = "true"
  }
}

#2 CREATE VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags       = local.common_tags
}

#3 DEPLOY THE PRIVATE SUBNETS
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.index)
  availability_zone = each.value.az
  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#4 DEPLOY THE PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.index + 100)
  availability_zone = each.value.az
  tags = {
    Name      = each.key
    Terraform = "true"
  }
}


#5 CREATE ROUTE TABLES FOR PUBLIC AND PRIVATE SUBNETS
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"  # Trasa lokalna w ramach VPC
  }
  tags = {
    Name      = "MyPrivateRouteTable"
    Terraform = "true"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "MyPublicRouteTable"
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

#7 CREATE IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

#8 CREATE SECURITY GROUP FOR EFS
resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

#9 CREATE EFS FILE SYSTEM
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs-token"
  encrypted      = true  # Włączenie szyfrowania
  tags           = local.common_tags
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = 1
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(values(aws_subnet.public_subnets), 0).id
  security_groups = [aws_security_group.efs_sg.id]
}
