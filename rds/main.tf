provider "aws" {
  region = var.region
}

# VPC
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group
resource "aws_security_group" "mysg" {
  vpc_id = data.aws_vpc.default.id
  name   = "db-sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
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

# DB subnet group
resource "aws_db_subnet_group" "dbgroup" {
  name       = "db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# RDS Instance

resource "aws_db_instance" "mydbinstance" {
  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  instance_class    = var.instance_class


  publicly_accessible = true
  multi_az            = false
  skip_final_snapshot = true
  storage_encrypted   = true

  vpc_security_group_ids = [aws_security_group.mysg.id]
  db_subnet_group_name   = aws_db_subnet_group.dbgroup.name

  db_name  = var.db_name
  username = var.username
  password = var.password

  tags = {
    Name = var.identifier
  }
}