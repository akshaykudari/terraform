provider "aws" {
  region = var.region
}

resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
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

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr_1
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.env}-public_1"
  }
}
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr_2
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"
  tags = {
    Name = "${var.env}-public_2"
  }
}
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr_1
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.env}-private_1"
  }
}
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr_2
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.env}-private_2"
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
resource "aws_route_table_association" "public_rt_assc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_assc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table_association" "private_rt_assc_1" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_1.id
}
resource "aws_route_table_association" "private_rt_assc_2" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_2.id
}