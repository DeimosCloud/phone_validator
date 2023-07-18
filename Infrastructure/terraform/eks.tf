module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.26"

   cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id  = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets #[module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  
    eks_managed_node_group_defaults = {
    disk_size = 50
  }

  
}



resource "aws_ecr_repository" "validator-backend" {
  name                 = var.backend_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "validator-frontend" {
  name                 = var.frontend_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}