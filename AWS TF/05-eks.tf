
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
    disk_size      = 20
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
    super-ng-public = {
      name           = "jeeves-ng-public"
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      instance_types = [var.instance_type]
      capacity_type  = "ON_DEMAND"

      ami_type = "AL2_x86_64"
      labels = {
        Environment = var.environment
      }

      tags = {
        Terraform = "true"
      }
    }
  }

  tags = local.common_tags
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.28.0-eksbuild.1"
  service_account_role_arn = module.eks.eks_managed_node_groups["super-ng-public"].iam_role_arn

  depends_on = [module.eks]
}

resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp2"
  }
  depends_on = [aws_eks_addon.ebs_csi]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::480926032159:user/kubeuser"
        username = "kubeuser"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks]
}