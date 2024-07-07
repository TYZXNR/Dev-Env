variable "region" {
  default = "us-east-2"
}

variable "environment" {
  default = "development"
}

variable "vpc_cidr" {
  description = "vpc cidr block"
}

variable "public_subnet_1_cidr" {
  description = "public subnet 1 cidr block"
}

variable "public_subnet_2_cidr" {
  description = "public subnet 2 cidr block"
}

variable "private_subnet_1_cidr" {
  description = "private subnet 1 cidr block"
}

variable "private_subnet_2_cidr" {
  description = "private subnet 2 cidr block"
}

variable "private_subnet_3_cidr" {
  description = "private subnet 3 cidr block"
}

variable "instance_type" {
  
}

variable "key_name" {
  
}