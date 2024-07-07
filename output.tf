output "ubuntu_server_ip_address" {
    value = aws_instance.ubuntu-server.public_ip
}