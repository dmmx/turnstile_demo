# AWS EC2 Instance Design Specification

## Overview
This document defines the design specification for an AWS EC2 instance that will be deployed in the public subnet. The instance will be provisioned using AWS CloudFormation YAML templates and deployed using the AWS CLI.

## Design Requirements

### EC2 Instance Configuration
- One **Public EC2 Instance** in the public subnet
- Instance will use **Amazon Linux 2023** AMI
- Instance type: **t2.micro**
- Instance will have a **10GB** root volume

### Network Configuration
- Instance will be associated with the public subnet and security group
- Instance will use the existing VPC infrastructure

### Storage Configuration
#### Root Volume
- Size: 10GB
- Volume Type: gp3
- Encrypted: true
- Delete on Termination: true

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