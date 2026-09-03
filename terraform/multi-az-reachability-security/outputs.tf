output "vpc_id" {
  description = "Lab 3B VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_a_id" {
  description = "Subnet A ID"
  value       = aws_subnet.a.id
}

output "subnet_b_id" {
  description = "Subnet B ID"
  value       = aws_subnet.b.id
}

output "instance_a_id" {
  description = "EC2-A instance ID"
  value       = aws_instance.a.id
}

output "instance_b_id" {
  description = "EC2-B instance ID"
  value       = aws_instance.b.id
}

output "instance_a_private_ip" {
  description = "EC2-A private IP"
  value       = aws_instance.a.private_ip
}

output "instance_b_private_ip" {
  description = "EC2-B private IP"
  value       = aws_instance.b.private_ip
}

output "security_group_a_id" {
  description = "EC2-A security group ID"
  value       = aws_security_group.a.id
}

output "security_group_b_id" {
  description = "EC2-B security group ID"
  value       = aws_security_group.b.id
}

output "iam_role_name" {
  description = "Shared SSM IAM role"
  value       = aws_iam_role.ssm.name
}