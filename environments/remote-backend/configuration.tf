terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.69.1"
    }
  }
}

provider "aws" {
  # Configuration options
  profile                  = var.aws_profile
  region                   = var.aws_region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-central-1"
}