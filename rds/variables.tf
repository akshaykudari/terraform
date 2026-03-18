variable "region" {
  type = string
}

# DB instnace
variable "identifier" {
  type = string
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "allocated_storage" {
  type = number
}
variable "storage_type" {
  type = string
}
variable "instance_class" {
  type = string
}



variable "db_name" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type      = string
  sensitive = true
}