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
    key            = "bastion/terraform.tfstate"
    dynamodb_table = "vertex-terra-backend-table"
    region         = "ap-south-1"
  }
}