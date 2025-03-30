# AWS VPC Design Specification

## Overview
This document defines the design specification for an AWS VPC. The VPC will include one public subnet and one private subnet, each with a capacity of 16 IP addresses. The networking rules will be enforced through security groups and route tables. The entire infrastructure will be provisioned using AWS CloudFormation YAML templates and deployed using the AWS CLI.

## Design Requirements

### VPC Configuration
- One **VPC** with CIDR block: `10.0.0.0/27`
- One **Public Subnet** with CIDR block: `10.0.0.0/28`
- One **Private Subnet** with CIDR block: `10.0.0.16/28`
- An **Internet Gateway (IGW)** attached to the VPC
- A **NAT Gateway** in the Public Subnet for outbound traffic from the Private Subnet
- Route tables configured to manage traffic flows appropriately

### Subnet Rules
#### Public Subnet
- Allows **SSH (22), HTTP (80), and HTTPS (443)** traffic from the public internet.
- Associated with a route table that directs all outbound traffic (`0.0.0.0/0`) to the Internet Gateway.

#### Private Subnet
- Allows **SSH (22), HTTP (80), and HTPS (443)** traffic only from the Public Subnet.
- Associated with a route table that directs outbound traffic through the NAT Gateway.

### Security Groups
#### Public Subnet Security Group
- Ingress:
  - **SSH (22)** from `0.0.0.0/0`
  - **HTTP (80)** from `0.0.0.0/0`
  - **HTTPS (443)** from `0.0.0.0/0`
- Egress:
  - Allow all outbound traffic

#### Private Subnet Security Group
- Ingress:
  - **SSH (22)** from Public Subnet
  - **HTTP (80)** from Public Subnet
  - **HTTPS (443)** from Public Subnet
- Egress:
  - Allow all outbound traffic

### Tags
All AWS resources will be tagged as follows:
| Key              | Value                                  |
|-----------------|--------------------------------------|
| dmmx:owner      | bdh61@me.com                         |
| dmmx:project    | turnstile                            |
| dmmx:create-date| 2025-03-30                           |
| dmmx:tr:owner   | dan.mohrland@thomsonreuters.com      |

## CloudFormation Implementation
The infrastructure will be deployed using AWS CloudFormation YAML templates. These templates will be processed by the AWS CLI to provision the required resources automatically.
