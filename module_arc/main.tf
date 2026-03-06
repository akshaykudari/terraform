# VPC module

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  public_cidr  = var.public_cidr
  private_cidr = var.private_cidr
  az           = var.az
}

# generating key locally

resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "file" {
  content         = tls_private_key.tls_private_key.private_key_pem
  filename        = "${var.key}.pem"
  file_permission = 0400
}
resource "aws_key_pair" "mykey" {
  key_name   = var.key
  public_key = tls_private_key.tls_private_key.public_key_openssh
}



# EC2 Module

module "ec2" {
  source = "./modules/ec2"

  ami           = var.ami
  instance_type = var.instance_type
  key           = aws_key_pair.mykey.key_name
  volume_size   = var.volume_size
  volume_type   = var.volume_type

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id

}