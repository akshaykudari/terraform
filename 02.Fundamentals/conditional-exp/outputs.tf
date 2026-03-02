output "public_ip" {
  value = [
    for k in aws_instance.myinstance : k.public_ip
  ]
}