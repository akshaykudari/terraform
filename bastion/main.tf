provider "aws" {
  region = var.region
}


# KEY Pair
resource "tls_private_key" "privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "mykey" {
  key_name   = var.key
  public_key = tls_private_key.privatekey.public_key_openssh
}
resource "local_file" "key_local" {
  content         = tls_private_key.privatekey.private_key_pem
  filename        = "${var.key}.pem"
  file_permission = 0400
}

#VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.env}-public-subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.env}-private-subnet"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    gateway_id = aws_internet_gateway.myigw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "${var.env}-public_rt"
  }
}
resource "aws_route_table_association" "public_assc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.env}-private_rt"
  }
}
resource "aws_route_table_association" "private_assc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}


# Security groups
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "${var.env}-public_sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "${var.env}-private_sg"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# EC2
resource "aws_instance" "myinstance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id              = aws_subnet.public.id
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "${var.env}-instance"
  }
  user_data = <<-E0F
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  sudo systemctl enable nginx --now
  E0F
}

resource "aws_instance" "private_instance" {
  ami                    = var.ami
  key_name               = aws_key_pair.mykey.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id              = aws_subnet.private.id
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "${var.env}-private_instance"
  }
}