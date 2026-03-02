provider "aws" {
  region = var.region
}

resource "aws_instance" "myinstance" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "variable-instance"
  }
}