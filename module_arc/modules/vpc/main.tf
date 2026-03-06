resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${terraform.workspace}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags = {
    Name = "${terraform.workspace}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr
  availability_zone = var.az
  tags = {
    Name = "${terraform.workspace}-private-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "${terraform.workspace}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${terraform.workspace}-private-rt"
  }
}
resource "aws_route_table_association" "private_rt_assc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}