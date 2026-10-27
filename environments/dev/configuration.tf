terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.69.1"
    }
  }

  # backend "s3" {
  #   bucket = "remote-backend-iauskhdfuiewhfiuksheefiuhefuk" 
  #   key    = "main-db/terraform.tfstate"
  #   region = "eu-central-1"
  # }
}


provider "aws" {
  # Configuration options
  profile                  = var.aws_profile
  region                   = var.aws_region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}