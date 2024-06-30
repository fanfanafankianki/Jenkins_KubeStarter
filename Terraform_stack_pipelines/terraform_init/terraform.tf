terraform {
  backend "remote" {
      hostname = "app.terraform.io"
      organization = "DevOps_Driven_Project"
      workspaces {
        name = "jenkins-workspace"
      }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}
