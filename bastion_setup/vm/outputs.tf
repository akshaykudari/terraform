output "public_ips" {
  value = aws_instance.myinstance.public_ip
}