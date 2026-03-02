variable "region" {
  type = string
}
variable "env" {
  type = string
}

# VPC variables
variable "vpc_cidr" {
  type = string
}
variable "public_cidr" {
  type = string
}
variable "private_cidr" {
  type = string
}
variable "az" {
  type = string
}



# EC2 variables
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "volume_type" {
  type = string
}
variable "volume_size" {
  type = number
}
variable "key" {
  type = string
}