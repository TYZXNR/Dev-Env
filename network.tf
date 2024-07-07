resource "aws_vpc" "devolopment-vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        name = "${var.environment}"
    }
}

#below are our two public subnet for our infrastructure, one in availability zone 2a and another in availability zone 2b

resource "aws_subnet" "public-subnet-1" {
    cidr_block = "${var.public_subnet_1_cidr}"
    vpc_id = aws_vpc.devolopment-vpc.id
    availability_zone = "${var.region}a"
    tags = {
      name = "${var.environment}-public-subnet-1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    cidr_block = "${var.public_subnet_2_cidr}"
    vpc_id = aws_vpc.devolopment-vpc.id
    availability_zone = "${var.region}b"
    tags = {
      name = "${var.environment}-public-subnet-2"
    }
}


#creating the public route table that will channel the traffic from the instances in the public subnet to the internet gateway and to the customer

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.devolopment-vpc.id
    tags = {
        name = "environment-public-route-table"
    }
  
}

#route table association are usually rules that are associate the subnet with a specific route table. They are usually used to define
#how the outbound traffic from the resources such as instances responds should be routed.

resource "aws_route_table_association" "route-table-association-1" {
    route_table_id = aws_route_table.public-route-table.id
    subnet_id = aws_subnet.public-subnet-1.id
  
}

#below are our three private subnets, one in availability zone 2a, next in availabilty zone 2b and the other one 2c

resource "aws_subnet" "private-subnet-1" {
    cidr_block = "${var.private_subnet_1_cidr}"
    vpc_id = aws_vpc.devolopment-vpc.id
    availability_zone = "${var.region}a"
    tags = {
      name = "${var.environment}-private-subnet-1"
    }
  
}

resource "aws_subnet" "private-subnet-2" {
    cidr_block = "${var.private_subnet_2_cidr}" #calculate the size of the network (2^(32-24)) =256
    vpc_id = aws_vpc.devolopment-vpc.id
    availability_zone = "${var.region}b"
    tags = {
      name = "${var.environment}-private-subnet-2"
    }
  
}

resource "aws_subnet" "private-subnet-3" {
    cidr_block = "${var.private_subnet_3_cidr}"
    vpc_id = aws_vpc.devolopment-vpc.id
    availability_zone = "${var.region}c"
    tags = {
      name = "${var.environment}-private-subnet-3"
    }
  
}

#private route table, has rules written on it on how to route resource outbound network from different destination
#such as vpc and internet gateway

resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.devolopment-vpc.id
    tags = {
        name = "${var.environment}-environment-private-route-table"
    }
  
}

#private route table association

resource "aws_route_table_association" "route-table-association-2" {
    route_table_id = aws_route_table.private-route-table.id
    subnet_id = aws_subnet.private-subnet-1.id
  
}

#internet gateway, it allows your instances within your vpc to connect with your internet and vise versa

resource "aws_internet_gateway" "vpc-internet-gateway" {
    vpc_id = aws_vpc.devolopment-vpc.id
    tags = {
      name = "${var.environment}-environment-igw"
    }
  
}

#aws route, it allows you to define how traffic should be directed within the vpc between the vpc and external links

resource "aws_route" "igw-route-public-internet" {
    route_table_id = aws_route_table.public-route-table.id
    gateway_id = aws_internet_gateway.vpc-internet-gateway.id
  
}

#elastic ip address is going to provide the resources in the private subnet with access to the internet

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "${var.environment}-environment-eip"
  }

}

#NAT Gateway allows instances in private subnets to access the internet for
#software updates, patching, and accessing external services, while keeping them protected from inbound traffic initiated from the internet.

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "${var.environment}-environment-natg"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw]
}

#aws route allows you to define how the traffic should be directed between vpc and the external
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}