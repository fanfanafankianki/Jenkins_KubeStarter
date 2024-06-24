terraform {
  backend "remote" {
      hostname = "app.terraform.io"
      organization = "DevOps_Driven_Project"
      workspaces {
        name = "main-workspace"
      }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}
