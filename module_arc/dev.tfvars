region = "ap-south-1"

# VPC
vpc_cidr     = "15.0.0.0/16"
public_cidr  = "15.0.1.0/24"
private_cidr = "15.0.2.0/24"
az           = "ap-south-1a"


# EC2
key           = "dev-key"
ami           = "ami-019715e0d74f695be"
instance_type = "t2.micro"
volume_size   = 20
volume_type   = "gp3"