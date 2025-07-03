
resource "aws_security_group" "rds_db_sg" {
  name        = "super_eks_rds_db_sg"
  description = "Allow MySQL port 3306 from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = merge({
    Name      = "super_eks_rds_db_sg"
    Terraform = "true"
    },
  local.common_tags)
}

resource "aws_db_subnet_group" "eks_rds_subnetgroup" {
  name       = "super_eks-rds-db-subnetgroup"
  subnet_ids = module.vpc.private_subnets

  tags = merge({
    Name      = "eks-rds-db-subnetgroup"
    Terraform = "true"
    }
    ,
  local.common_tags)
}

resource "aws_db_instance" "usermanagement" {
  identifier              = "dbusermanagementdb"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.medium"
  db_name                 = "usermanagement"
  username                = "dbadmin"
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.eks_rds_subnetgroup.name
  storage_type            = "gp2"
  backup_retention_period = 7
  multi_az                = false

  tags = merge({
    Name      = "dbusermanagementdb"
    Terraform = "true"
    }
    ,
  local.common_tags)
}
