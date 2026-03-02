provider "aws" {
  region = var.region
}

# VPC
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
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr_1
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr_2
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route" "default" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.myigw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_1_assc" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}
resource "aws_route_table_association" "public_2_assc" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_2.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "${var.env}-alb_sg"
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
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "${var.env}-web_sg"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ALB
resource "aws_alb" "alb" {
  name               = "${var.env}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
  aws_subnet.public_1.id, aws_subnet.public_2.id]
}
resource "aws_alb_target_group" "tg" {
  name     = "${var.env}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}
resource "aws_alb_listener" "listener" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_alb.alb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

# Web servers
resource "aws_instance" "myinstance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  count                  = 2
  subnet_id              = [aws_subnet.public_1.id, aws_subnet.public_2.id][count.index]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<-E0F
    #!/bin/bash
    sudo apt update && sudo apt install apache2 -y
    sudo systemctl enable apache2 --now
    echo "Hello from ${count.index} ">/var/www/html/index.html
    E0F
  tags = {
    Name = "Instance${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = 2
  target_group_arn = aws_alb_target_group.tg.arn
  target_id        = aws_instance.myinstance[count.index].id
  port             = 80
}