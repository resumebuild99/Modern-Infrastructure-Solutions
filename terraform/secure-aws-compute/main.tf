terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.59"
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
# VPC
# ------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lab3a-secure-compute-vpc"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Public subnet
# ------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab3a-public-subnet"
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
    Name        = "lab3a-igw"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Public route table
# ------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "lab3a-public-rt"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------
# Security group
# ------------------------------------------------------------

resource "aws_security_group" "ec2" {
  name        = "lab3a-ec2-sg"
  description = "Security group for Lab 3A EC2 instance"
  vpc_id      = aws_vpc.main.id

  # No inbound SSH rule.
  # Management is intended through AWS Systems Manager.

  egress {
    description = "Allow outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "lab3a-ec2-sg"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# IAM role for Systems Manager
# ------------------------------------------------------------

resource "aws_iam_role" "ssm" {
  name = "lab3a-ec2-ssm-role"

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
    Name        = "lab3a-ec2-ssm-role"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "lab3a-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}

# ------------------------------------------------------------
# EC2
# ------------------------------------------------------------

resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = "lab3a-secure-compute"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}