variable "vpc_name" {
  type    = string
  default = "devops_project_vpc"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "MyPrivateSubnet1" = { "index" = 1, "az" = "eu-north-1a" }
    "MyPrivateSubnet2" = { "index" = 2, "az" = "eu-north-1b" }
  }
}

variable "public_subnets" {
  default = {
    "MyPublicSubnet1" = { "index" = 1, "az" = "eu-north-1a" }
    "MyPublicSubnet2" = { "index" = 2, "az" = "eu-north-1b" }
  }
}
