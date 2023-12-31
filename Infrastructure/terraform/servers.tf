#-------------------------
#   Servers
#-------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 4.66.0"

  name = var.load_balancer

  ami                         = var.linux_ami
  instance_type               = var.linux_instance_type
  key_name                    = "loadbalancer"
  monitoring                  = true
  vpc_security_group_ids      = [module.lb_security_group.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

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
              sudo yum install iptables nginx -y
              sudo service nginx start
              sudo chkconfig nginx on

              sudo sed -i 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
              sudo service sshd restart
              EOF


  tags = merge(
    local.common_labels,
    {
      Name = "load_balancer",
    }
  )
}


module "microservice" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 4.66.0"

  name = var.microservice

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "microservice"
  monitoring             = true
  vpc_security_group_ids = [module.ms_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[1]

  create_iam_instance_profile = true
  iam_role_description        = "Allow ECR access"

  iam_role_policies = {
    AmazonEC2ContainerRegistryFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    AmazonEC2ContainerServiceforEC2Role  = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"

  }

  # iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker iptables -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on

            
              sudo sed -i 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
              sudo service sshd restart
              EOF

  tags = merge(
    local.common_labels,
    {
      Name = "microservice"
    }
  )
}


module "ansible_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.ansible_master

  ami                         = var.linux_ami
  instance_type               = var.linux_instance_type
  key_name                    = "ansible_master"
  monitoring                  = true
  vpc_security_group_ids      = [module.ansible_master_security_group.security_group_id]
  subnet_id                   = module.vpc.public_subnets[1]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install python3-pip -y
              python3 -m pip install 
              sudo yum install ansible -y
              EOF

  tags = merge(
    local.common_labels,
    {
      Name = "master-node"
    }
  )
}

#----------------------------

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ssm_role_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ssm_role.name
}


resource "aws_iam_role" "full_eks_role" {
  name = "full_eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "full_eks_policy" {
  name        = "full_eks_policy"
  description = "Full EKS policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "full_eks_role_attachment" {
  role       = aws_iam_role.full_eks_role.name
  policy_arn = aws_iam_policy.full_eks_policy.arn
}

resource "aws_iam_instance_profile" "full_eks_profile" {
  name = "load_balancer"
  role = aws_iam_role.full_eks_role.name
}

