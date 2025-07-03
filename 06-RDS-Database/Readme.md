
# AWS RDS MySQL Database Setup Guide

This guide describes the steps to create and configure an Amazon RDS MySQL database instance inside an Amazon VPC with private subnets. It covers security group setup, subnet group creation, and launching the RDS instance.

---

## Overview

- **VPC (Virtual Private Cloud)**: A logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define.
- **Subnets**: Segments of the VPC IP address range where you can place groups of isolated resources. Here, we use private subnets to host the RDS instance for security and isolation.
- **Security Groups**: Virtual firewalls to control inbound and outbound traffic to AWS resources. We create a security group to allow inbound MySQL traffic on port 3306.

---

## Steps to Setup AWS RDS MySQL

### 1. Create a Security Group for RDS

Create a security group inside your VPC that allows inbound MySQL traffic on port 3306 from anywhere (0.0.0.0/0).  
**Note:** Allowing traffic from anywhere is for testing purposes. In production, restrict this to trusted IP ranges or other security groups.

```bash
aws ec2 create-security-group \
  --group-name eks_rds_db_sg \
  --description "Allow MySQL port 3306 from anywhere" \
  --vpc-id vpc-04a4394a6464a274b \
  --region ap-southeast-2
```

Example output:

```json
{
  "GroupId": "sg-056ebf9932919523f",
  "SecurityGroupArn": "arn:aws:ec2:ap-southeast-2:480926032159:security-group/sg-056ebf9932919523f"
}
```

### 2. Authorize Ingress Traffic on Port 3306

Allow inbound TCP traffic on port 3306 (MySQL) from any IP address:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-056ebf9932919523f \
  --protocol tcp \
  --port 3306 \
  --cidr 0.0.0.0/0 \
  --region ap-southeast-2
```

---

### 3. Create an RDS DB Subnet Group

Define the subnet group for your RDS instance. This groups the private subnets where your RDS will reside.

```bash
aws rds create-db-subnet-group \
  --db-subnet-group-name eks-rds-db-subnetgroup \
  --db-subnet-group-description "Subnet group for EKS RDS private subnets" \
  --subnet-ids subnet-0cac0daf4a4d6f39a subnet-06413f78751e0bff1 \
  --tags Key=Name,Value=eks-rds-db-subnetgroup \
  --region ap-southeast-2
```

You can verify the subnets and their CIDR blocks with:

```bash
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-04a4394a6464a274b" \
  --query "Subnets[?contains(['192.168.64.0/19','192.168.96.0/19'], CidrBlock)] | [].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone}" \
  --region ap-southeast-2
```

Example output:

```json
[
  {
    "ID": "subnet-0cac0daf4a4d6f39a",
    "CIDR": "192.168.64.0/19",
    "AZ": "ap-southeast-2a"
  },
  {
    "ID": "subnet-06413f78751e0bff1",
    "CIDR": "192.168.96.0/19",
    "AZ": "ap-southeast-2b"
  }
]
```

---

### 4. Create the RDS MySQL Database Instance

Launch the RDS instance with the following configuration:

- MySQL engine version 8.0
- 20GB storage with gp2 type
- db.t3.micro instance class
- Master username and password
- Use private subnets and security group created earlier
- No public accessibility (database not exposed publicly)

```bash
aws rds create-db-instance \
  --db-instance-identifier dbusermgmtdb \
  --allocated-storage 20 \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0 \
  --master-username dbadmin \
  --master-user-password dbpassword11 \
  --db-name usermgmt \
  --vpc-security-group-ids sg-056ebf9932919523f \
  --db-subnet-group-name eks-rds-db-subnetgroup \
  --port 3306 \
  --no-publicly-accessible \
  --storage-type gp2 \
  --backup-retention-period 7 \
  --no-multi-az \
  --auto-minor-version-upgrade \
  --tags Key=Name,Value=dbusermgmtdb \
  --region ap-southeast-2
```

---

## Key Concepts Explained

### VPC (Virtual Private Cloud)

A VPC is a virtual network dedicated to your AWS account, isolated from other networks. It lets you define your own IP address ranges, subnets, route tables, and network gateways.

### Private Subnets

Subnets within your VPC can be public or private. Private subnets do not have direct internet access, enhancing security for resources like databases. Here, the RDS instance is placed in private subnets (`192.168.64.0/19` and `192.168.96.0/19`), restricting direct internet exposure.

### Security Groups

Security groups act as virtual firewalls controlling inbound and outbound traffic. In this setup, the security group `eks_rds_db_sg` allows inbound MySQL traffic on port 3306. This security group is attached to the RDS instance to allow controlled access.

---

## Notes

- For production, avoid opening the database port to the entire internet (`0.0.0.0/0`). Instead, restrict access to trusted IP addresses or AWS resources.
- You can enhance security by enabling Multi-AZ deployments, encryption, and setting stricter security group rules.
- Always keep your database credentials secure and consider using AWS Secrets Manager for managing them.

---

## References

- [Amazon RDS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- [VPC and Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Security Groups for EC2 Instances](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

---

*This README was generated to assist in setting up an AWS RDS MySQL instance with proper network and security configurations.*
