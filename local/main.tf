resource "local_file" "local_file" {
  content  = "hello world..!"
  filename = "file.txt"
}