# Lab 3A — Secure AWS Compute

## Objective

Provision a small AWS compute environment with Terraform and secure
management through AWS Systems Manager rather than exposing SSH.

## Architecture

- AWS Region: ap-southeast-2
- VPC: 10.30.0.0/16
- Public Subnet: 10.30.1.0/24
- Internet Gateway
- Public Route Table
- EC2 instance
- EC2 Security Group
- IAM Role
- IAM Instance Profile
- AWS Systems Manager integration

## Security Design

Inbound SSH is intentionally not exposed.

The EC2 instance receives an IAM role containing
`AmazonSSMManagedInstanceCore` so the instance can be managed through
AWS Systems Manager.

## Terraform Concepts

- variables
- data sources
- resource references
- implicit dependencies
- IAM role and instance profile
- security groups
- EC2 attributes
- outputs
- plan/apply
- verification
- controlled destroy

## Evidence

Evidence is stored under:

`evidence/`

Terraform state, `.terraform/`, credentials, and other runtime artifacts
remain local and are not committed.

## Lifecycle

Build
→ Verify
→ Capture Evidence
→ Sanitize
→ Commit
→ Push
→ Destroy
→ Verify Cleanup