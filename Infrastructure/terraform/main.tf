locals {

  common_labels = {

    environment = var.environment
    managed_by  = "terraform"
  }

}

#-------------------------
#   VPC
#-------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs              = var.availability_zones
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

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


  tags = local.common_labels
}


module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.load_balancer
  description = "Complete PostgreSQL example security group"
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
  description = "Complete PostgreSQL example security group"
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




#-------------------------
#   Servers
#-------------------------



module "load_balancer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.load_balancer

  ami                    = var.linux_ami
    instance_type          = var.linux_instance_type
  key_name               = "Mobi-key-dev"
  monitoring             = true
  vpc_security_group_ids = [module.lb_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets.id

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              sudo chkconfig nginx on
              EOF



  tags = local.common_labels
}


module "microservice" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.microservice

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = ""
  monitoring             = true
  vpc_security_group_ids = [module.ms_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              EOF



  tags = local.common_labels
}

#-------------------------
#   Database
#-------------------------

module "postgresql" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "phone_validator"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100


  db_name  = var.db_name
  username = "jumia"
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.db_security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.common_labels
}

