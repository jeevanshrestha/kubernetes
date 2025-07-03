
# DynamoDB Table
resource "aws_dynamodb_table" "user_data" {
  name           = "user-data-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }

  tags = merge(
    {
      Name = "user-data-table"
    },
    local.common_tags
  )
}

# VPC Endpoint for DynamoDB (to allow private access from EKS)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = merge(
    {
      Name = "dynamodb-vpc-endpoint"
    },
    local.common_tags
  )
}

# IAM Policy for EKS to access DynamoDB
resource "aws_iam_policy" "dynamodb_access" {
  name        = "EKS-DynamoDB-Access-Policy"
  description = "Policy for EKS to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource = [
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.user_data.name}",
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.user_data.name}/index/*"
        ]
      }
    ]
  })
}

# Attach DynamoDB policy to EKS node role
resource "aws_iam_role_policy_attachment" "eks_dynamodb_access" {
  policy_arn = aws_iam_policy.dynamodb_access.arn
  role       = module.eks.eks_managed_node_groups["super-ng-public"].iam_role_name
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}