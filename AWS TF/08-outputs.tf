output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.usermanagement.endpoint
}

output "node_group_role_arn" {
  description = "ARN of the node group IAM role"
  value       = module.eks.eks_managed_node_groups["super-ng-public"].iam_role_arn
}


output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.user_data.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.user_data.arn
}

output "dynamodb_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}


output "node_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.eks.eks_managed_node_groups["super-ng-public"].iam_role_arn
}

output "ebs_policy_arn" {
  description = "ARN of the Amazon EBS CSI Driver Policy"
  value       = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
