variable "region" {
  type = string
}
variable "env" {
  type = string
}

#VPC
variable "vpc_cidr" {
  type = string
}
variable "public_cidr_1" {
  type = string
}
variable "public_cidr_2" {
  type = string
}



# EC2
variable "instance_type" {
  type = string
}
variable "ami" {
  type = string
}

