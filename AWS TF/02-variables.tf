# variables.tf
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "jeeves-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "date" {
  description = "Deployment date"
  type        = string
  default     = "2025-06-26"
}

variable "creator" {
  description = "Creator name"
  type        = string
  default     = "Jeevan"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "jeeves"
}

variable "db_password" {
  description = "Password for RDS MySQL database"
  type        = string
  sensitive   = true
}
 