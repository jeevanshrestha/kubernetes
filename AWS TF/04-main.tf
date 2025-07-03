locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Date        = var.date
    Creator     = var.creator
    Project     = var.project
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "jeevescluster-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["192.168.64.0/19", "192.168.96.0/19"]
  public_subnets  = ["192.168.0.0/19", "192.168.32.0/19"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "jeevescluster-vpc"
    },
    local.common_tags
  )

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
