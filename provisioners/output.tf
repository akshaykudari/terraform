output "url" {
  value = "http://${aws_instance.myinstance.public_ip}:80"
}