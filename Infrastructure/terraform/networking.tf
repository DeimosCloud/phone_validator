#-------------------------
#   VPC
#-------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs              = var.availability_zones
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.common_labels
}

#-------------------------
#   Security Group
#-------------------------

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.db_name
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

  ]
  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp",
      source_security_group_id = module.ms_security_group.security_group_id
    },
    {
      rule                     = "http-80-tcp",
      source_security_group_id = module.ms_security_group.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2


  tags = local.common_labels
}


module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.load_balancer
  description = "loadbalancer security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  tags = local.common_labels
}


# ********** Microservice SG**********
module "ms_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.microservice
  description = "Complete microservice security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp",
      source_security_group_id = module.lb_security_group.security_group_id
    },
    {
      rule                     = "http-80-tcp",
      source_security_group_id = module.lb_security_group.security_group_id
    },
    {
      from_port                = 32009 # NodePort for loadbalancer
      to_port                  = 32009
      protocol                 = "tcp"
      source_security_group_id = module.lb_security_group.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  tags = local.common_labels
}

#-------------------------
#   Ansible master SG
#-------------------------
module "ansible_master_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.ansible_master
  description = "ansible master security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  tags = local.common_labels
}