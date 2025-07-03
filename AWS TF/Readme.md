# Super Terraform AWS EKS CLuster Setup with MYSQL-RDS and DynamoDB

## Overview

This project demonstrates an automated AWS infrastructure setup using Terraform for a production-grade Kubernetes environment. It includes:

* Amazon EKS cluster and managed node group
* VPC with public and private subnets
* RDS MySQL instance
* DynamoDB table with VPC endpoint
* Kubernetes storage class for EBS CSI driver
* IAM policies for secure access to DynamoDB from EKS nodes

## Prerequisites

* Terraform >= 1.0.0
* AWS CLI configured with appropriate IAM permissions
* kubectl installed and configured

## Providers

The following Terraform providers are used:

* AWS: \~> 5.0
* Kubernetes: \~> 2.0

## Variables

Ensure the following variables are set in your `terraform.tfvars` or equivalent:

* `region`: AWS region (e.g., `ap-southeast-2`)
* `environment`: Environment name (e.g., `dev`)
* `date`: Deployment date
* `creator`: Your name or automation system
* `project`: Project identifier
* `db_password`: RDS admin user password

## Modules

### VPC

Creates a VPC with public and private subnets, NAT gateway, and DNS hostnames. Subnets are tagged for Kubernetes ELB and internal ELB usage.

### EKS Cluster

Creates an EKS cluster with managed node group (`t3.micro`), version `1.27`, and appropriate IAM role policies for CSI driver and DynamoDB access.

### Kubernetes Provider

Configured using the output from the EKS module to interact with the cluster.

## Resources

### Security Group

Creates a security group to allow EKS nodes to access the RDS instance on port 3306.

### RDS MySQL

Sets up an RDS MySQL instance within the private subnets of the VPC. The database is not publicly accessible and has backups enabled for 7 days.

### DB Subnet Group

Defines a subnet group for RDS using the private subnets.

### Kubernetes Storage Class

Creates a Kubernetes storage class named `ebs-sc` using the EBS CSI driver, with `WaitForFirstConsumer` volume binding mode.

### DynamoDB Table

Creates a DynamoDB table named `user-data-table` with provisioned capacity and a hash key `UserID`.

### VPC Endpoint for DynamoDB

Creates a VPC Gateway Endpoint for DynamoDB to enable private access from within the VPC.

### IAM Policy

Defines a custom IAM policy that allows EKS node IAM roles to perform CRUD operations on the DynamoDB table.

### IAM Policy Attachment

Attaches the DynamoDB access policy to the IAM role of the EKS node group.

## Deployment Steps

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Preview the changes:

   ```bash
   terraform plan -out=tfplan
   ```

3. Apply the configuration:

   ```bash
   terraform apply tfplan
   ```

4. Update your Kubernetes context:

   ```bash
   aws eks update-kubeconfig --name supercluster --region <your-region>
   ```

5. Verify EKS cluster:

   ```bash
   kubectl get nodes
   ```

## Post-Deployment Notes

* Ensure the RDS instance is only accessible from within the VPC or via bastion/jump host.
* You can mount volumes using the `ebs-sc` storage class inside your Kubernetes workloads.
* Use AWS CloudWatch or other monitoring solutions to track cluster and database metrics.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Author

Jeevan Shrestha

## License

This project is intended for educational and demonstration purposes. No license specified.

> **Note:**  
> Provisioning all resources described in this setup may take up to one hour to complete, depending on your AWS region and resource availability.
