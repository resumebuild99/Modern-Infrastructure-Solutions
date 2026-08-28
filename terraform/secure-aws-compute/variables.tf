variable "aws_region" {
  description = "AWS region for Lab 3A"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile used for Lab 3A"
  type        = string
  default     = "bootcamp"
}

variable "vpc_cidr" {
  description = "CIDR block for the Lab 3A VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the Lab 3A public subnet"
  type        = string
  default     = "10.30.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
  default     = "ap-southeast-2a"
}

variable "instance_type" {
  description = "EC2 instance type for Lab 3A"
  type        = string
  default     = "t3.micro"
}