output "vpc_id" {
  description = "Lab 3A VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Lab 3A public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Lab 3A EC2 security group ID"
  value       = aws_security_group.ec2.id
}

output "instance_id" {
  description = "Lab 3A EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "Lab 3A EC2 private IP"
  value       = aws_instance.main.private_ip
}

output "instance_public_ip" {
  description = "Lab 3A EC2 public IP"
  value       = aws_instance.main.public_ip
}

output "iam_role_name" {
  description = "IAM role attached to the EC2 instance profile"
  value       = aws_iam_role.ssm.name
}

output "instance_profile_name" {
  description = "IAM instance profile attached to the EC2 instance"
  value       = aws_iam_instance_profile.ssm.name
}