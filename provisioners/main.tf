provider "aws" {
  region = var.region
}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mykeypair" {
  key_name   = var.key
  public_key = tls_private_key.mykey.public_key_openssh
}

resource "local_file" "local_key" {
  content         = tls_private_key.mykey.private_key_openssh
  filename        = "${var.key}.pem"
  file_permission = "0400"
}

data "aws_vpc" "myvpc" {
  default = true
}

resource "aws_security_group" "mysg" {
  name   = "mysg"
  vpc_id = data.aws_vpc.myvpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
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
  key_name      = aws_key_pair.mykeypair.key_name
  ami           = var.ami
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.root_volume
    volume_type = var.root_volume_type
  }
  vpc_security_group_ids = [aws_security_group.mysg.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.mykey.private_key_openssh
    host        = self.public_ip
    timeout     = "5m"
  }


  provisioner "remote-exec" {
    scripts = [
      "nginx.sh",
      "deploy.sh"
    ]
  }
  tags = {
    Name = "${var.region}_instance"
  }
}