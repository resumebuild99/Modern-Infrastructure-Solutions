terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = "bootcamp"
}

resource "aws_s3_bucket" "terraform_test" {
  bucket = "modern-infrastructure-terraform-test-2026"

  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Infrastructure Automation"
  }
}