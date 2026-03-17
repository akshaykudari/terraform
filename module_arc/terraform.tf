terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    local = {
      source = "hashicorp/local"
    }
  }
  backend "s3" {
    bucket         = "vertex-terra-backend-bucket"
    dynamodb_table = "vertex-terra-backend-table"
    key            = "module/terraform.tfstate"
    region         = "ap-south-1"
  }
}

provider "aws" {
  region = var.region
}