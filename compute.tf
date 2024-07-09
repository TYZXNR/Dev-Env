data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu-server" {
  ami = "ami-094be4c7f1e506a7a"  
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  subnet_id = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [ aws_security_group.sg-allow-allubuntu.id ]
  user_data = "${file("ubuntu.sh")}"
  associate_public_ip_address = true
  tags = {
    name = "${var.environment}-ubuntu-server-1"
  }
}

#security groups in aws are virtual firewalls they are used to control the traffic coming in and out of resources such as instances
#they are called stateful rules

resource "aws_security_group" "sg-allow-allubuntu" {
  name = "allow-traffic-ubuntu"
  description = "allow traffic in and out of the ubuntu server"
  vpc_id = aws_vpc.devolopment-vpc.id

  ingress {
    from_port = 22  #we use it for ssh, its used for scp (secure copy), used for sftp (secure file transfer protocols)
    to_port = 22
    protocol = "tcp" #(transmission control protocol) (tcp any connection that involves ssh, https, http eg shaking hands)
                   #(udp playing games, waving hands from a distance) 
    cidr_blocks = ["0.0.0.0.0/0"]               
  }

  ingress {
    from_port = 80  #port 80 is by default in which the http traffic passes through
    to_port = 80
    protocol = "tcp" #(transmission control protocol) (tcp any connection that involves ssh, https, http eg shaking hands)
                   #(udp playing games, waving hands from a distance) 
    cidr_blocks = ["0.0.0.0.0/0"]
  }

  ingress {
    from_port = 443  #used for web communication for encrypted communication between the web server of the company and the web browser of the user. its secure because of ssl, secure socket layer, its given by trusted authorities
    to_port = 443
    protocol = "tcp" #(transmission control protocol) (tcp any connection that involves ssh, https, http eg shaking hands)
                   #(udp playing games, waving hands from a distance) 
    cidr_blocks = ["0.0.0.0.0/0"]               
  }

  ingress {
    from_port = 8080  #it is an alternative port for port 80
    to_port = 8080
    protocol = "tcp" #(transmission control protocol) (tcp any connection that involves ssh, https, http eg shaking hands)
                   #(udp playing games, waving hands from a distance) 
    cidr_blocks = ["0.0.0.0.0/0"]               
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" #(all outgoing traffic)
    cidr_blocks = ["0.0.0.0.0/0"]               
  }
}

