#ebs elastic block store is a highly performance and highly scalable used to persist data
resource "aws_ebs_volume" "ubuntu-server-volume" {
  availability_zone = "${var.region}a"
  size = 100
}

resource "aws_volume_attachment" "ubuntu-server-ebs" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.ubuntu-server-volume.id
  instance_id = aws_instance.ubuntu-server.id
}