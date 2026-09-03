terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ------------------------------------------------------------
# AMI
# ------------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ------------------------------------------------------------
# Availability Zones
# ------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lab3b-multi-az-vpc"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Subnet A
# ------------------------------------------------------------

resource "aws_subnet" "a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_a_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab3b-subnet-a"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Subnet B
# ------------------------------------------------------------

resource "aws_subnet" "b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_b_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab3b-subnet-b"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "lab3b-igw"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Shared public route table
#
# The interesting traffic in this lab is NOT routed through
# the Internet Gateway. EC2-A and EC2-B communicate using
# the VPC's built-in local route.
# ------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "lab3b-public-rt"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------
# IAM ROLE / INSTANCE PROFILE FOR SSM
# ------------------------------------------------------------

resource "aws_iam_role" "ssm" {
  name = "lab3b-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "lab3b-ec2-ssm-role"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "lab3b-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}

# ------------------------------------------------------------
# SECURITY GROUP A
#
# EC2-A may:
#   - reach AWS services over HTTPS
#   - reach EC2-B on TCP/80
#
# No inbound SSH.
# ------------------------------------------------------------

resource "aws_security_group" "a" {
  name        = "lab3b-ec2-a-sg"
  description = "Security group for Lab 3B EC2-A"
  vpc_id      = aws_vpc.main.id

  egress {
    description     = "Allow HTTPS to AWS/services"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }

  egress {
    description = "Allow HTTP to EC2-B subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_b_cidr]
  }

  tags = {
    Name        = "lab3b-ec2-a-sg"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# SECURITY GROUP B
#
# EC2-B accepts HTTP only from EC2-A's security group.
#
# There is intentionally NO TCP/22 ingress rule.
# ------------------------------------------------------------

resource "aws_security_group" "b" {
  name        = "lab3b-ec2-b-sg"
  description = "Security group for Lab 3B EC2-B"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from EC2-A"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.a.id]
  }

  egress {
    description = "Allow HTTPS to AWS/services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "lab3b-ec2-b-sg"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# EC2-A
#
# Installs ncat for controlled connectivity testing.
# ------------------------------------------------------------

resource "aws_instance" "a" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.a.id
  vpc_security_group_ids      = [aws_security_group.a.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nmap-ncat
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = "lab3b-ec2-a"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# EC2-B
#
# Installs nginx and ncat.
# nginx provides a real TCP/80 service for the positive test.
# ------------------------------------------------------------

resource "aws_instance" "b" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.b.id
  vpc_security_group_ids      = [aws_security_group.b.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx nmap-ncat
    systemctl enable --now nginx
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = "lab3b-ec2-b"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}