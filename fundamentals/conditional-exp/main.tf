
provider "aws" {
  region = var.region
}
provider "local" {

}
provider "tls" {

}

resource "tls_private_key" "private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "mykey" {
  key_name   = var.key
  public_key = tls_private_key.private.public_key_openssh
}
resource "local_file" "local_key" {
  content         = tls_private_key.private.private_key_pem
  filename        = "${var.key}.pem"
  file_permission = 0400
}

resource "aws_default_vpc" "default" {

}
resource "aws_security_group" "mysg" {
  vpc_id = aws_default_vpc.default.id
  name   = "${var.env}-sg"
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

resource "aws_instance" "myinstance" {
  for_each = tomap({
    "${var.env}-1" = "t2.micro",
    "${var.env}-2" = "t2.micro"
  })
  ami                    = var.ami
  instance_type          = var.env == "prd" ? "t2.large" : each.value
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.mysg.id]
  tags = {
    Name = each.key
  }
  root_block_device {
    volume_size = var.env == "prd" ? 20 : var.volume_size
    volume_type = var.volume_type
  }
}