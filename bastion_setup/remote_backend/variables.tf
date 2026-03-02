variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "bucket_name" {
  type    = string
  default = "vertex-terra-backend-bucket"
}
variable "table_name" {
  type    = string
  default = "vertex-terra-backend-table"
}