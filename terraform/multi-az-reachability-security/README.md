# Lab 3B — Multi-AZ Reachability & Security

## Objective

Demonstrate network reachability and Security Group enforcement between
two EC2 instances located in different Availability Zones within the
same VPC.

## Network

VPC:
10.40.0.0/16

Subnet A:
10.40.10.0/24

Subnet B:
10.40.20.0/24

## Workloads

EC2-A:
Source/test client

EC2-B:
HTTP test server

Both instances are managed through AWS Systems Manager.
Inbound SSH is intentionally not configured.

## Traffic Matrix

| Source | Destination | Port | Expected |
|--------|-------------|------|----------|
| EC2-A | EC2-B | TCP/80 | ALLOW |
| EC2-A | EC2-B | TCP/22 | DENY |
| EC2-B | EC2-A | TCP/80 | DENY |
| EC2-B | EC2-A | TCP/22 | DENY |

## Core Networking Lesson

Traffic between the two subnets uses the VPC's local routing.

Security Groups then determine whether the traffic is permitted.

The lab therefore demonstrates:

Routing:
"Can the packet reach the destination?"

Security:
"Is the packet allowed?"

## Functional Test

### Positive test

EC2-A -> EC2-B TCP/80

Expected:
PASS

### Negative test

EC2-A -> EC2-B TCP/22

Expected:
BLOCKED

## Security Design

- No inbound SSH
- EC2 management through Systems Manager
- EC2-B HTTP access restricted to EC2-A's Security Group
- TCP/22 intentionally not permitted

## Lifecycle

Build
-> Verify
-> Functional Test
-> Capture Evidence
-> Commit
-> Push
-> Destroy
-> Verify Cleanup