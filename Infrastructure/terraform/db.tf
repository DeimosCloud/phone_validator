locals {

  common_labels = {

    environment = var.environment
    managed_by  = "terraform"
  }

}
#-------------------------
#   Database
#-------------------------

# resource "aws_db_instance" "postgres_db" {
#   allocated_storage             = var.db_allocated_storage
#   db_name                       = var.db_name
#   engine                        = var.db_engine
#   engine_version                = var.db_engine_version
#   instance_class                = var.db_instance_class
#   username                      = var.db_username
#   multi_az                      = true
#   parameter_group_name          = aws_db_parameter_group.postgres_db.name
#   manage_master_user_password   = true
#   master_user_secret_kms_key_id = aws_kms_key.db_secret.key_id
#   db_subnet_group_name          = module.vpc.database_subnet_group
#   skip_final_snapshot           = true

#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "aws_db_parameter_group" "postgres_db" {
#   name   = "postgres-db-pg"
#   family = "postgres14"

#   parameter {
#     name  = "log_connections"
#     value = "1"
#   }
# }


# resource "aws_kms_key" "db_secret" {
#   description             = "KMS key for postgres RDS"
#   deletion_window_in_days = 10
#   tags                    = local.common_labels
# }


module "postgres_db" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 4.66.0"

  name = var.db_name

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "postgres"
  monitoring             = true
  vpc_security_group_ids = [module.db_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]
  # subnet_id              = module.vpc.database_subnets[0]

  # iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  create_iam_instance_profile = true
  iam_role_description        = "Allow EKS access"
  iam_role_policies = {
    AmazonEKSClusterPolicy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    AmazonEKSServicePolicy = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    EKSFullAccess          = aws_iam_policy.full_eks_policy.arn
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install iptables python3-pip -y
              sudo dnf install postgresql15.x86_64 postgresql15-server -y
              sudo postgresql-setup --initdb
              pip install --upgrade pip
              pip install psycopg2
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              

              sudo sed -i 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
              sudo service sshd restart
              EOF

  tags = merge(
    local.common_labels,
    {
      Name = "Postgres_DB"
    }
  )
}