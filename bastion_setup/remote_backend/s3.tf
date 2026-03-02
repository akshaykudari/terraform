provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}