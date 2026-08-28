# Lab 3A Evidence — Public Copy

This folder contains curated, sanitized evidence for the completed
**Secure AWS Compute with Terraform** lab.

Evidence layers:
1. `terraform-verification.txt` — Terraform-managed configuration/state summary.
2. `aws-verification.txt` — independent AWS CLI verification summary.
3. `functional-test.txt` — SSM registration and Run Command functional result.
4. `destroy-verification.txt` — controlled Terraform destruction result.
5. `post-destroy.txt` — post-destroy resource and EBS verification.

The public copy intentionally omits:
- AWS account identifiers
- resource IDs
- ARNs and IAM unique IDs
- public/private IP addresses
- command IDs
- raw Terraform state
- `.terraform/`
- Terraform plan files

The original raw command outputs may be retained locally for audit/training
purposes and should not be committed unless explicitly reviewed.
