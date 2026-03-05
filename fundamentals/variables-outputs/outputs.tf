output "public_ip" {
  value = aws_instance.myinstance.public_ip
}
output "public_dns" {
  value = aws_instance.myinstance.public_dns
}