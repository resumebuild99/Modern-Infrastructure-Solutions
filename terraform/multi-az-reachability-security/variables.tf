variable "aws_region" {
  description = "AWS region for Lab 3B"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile for Lab 3B"
  type        = string
  default     = "bootcamp"
}

variable "vpc_cidr" {
  description = "CIDR block for the Lab 3B VPC"
  type        = string
  default     = "10.40.0.0/16"
}

variable "subnet_a_cidr" {
  description = "CIDR block for subnet A"
  type        = string
  default     = "10.40.10.0/24"
}

variable "subnet_b_cidr" {
  description = "CIDR block for subnet B"
  type        = string
  default     = "10.40.20.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for Lab 3B"
  type        = string
  default     = "t3.micro"
}