#-------------------------
#   Servers
#-------------------------



module "load_balancer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.load_balancer

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "loadbalancer"
  monitoring             = true
  vpc_security_group_ids = [module.lb_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              sudo chkconfig nginx on
              EOF


 tags = merge (
    local.common_labels,
    {
      Name = "load_balancer"
    }
 )
}


module "microservice" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.microservice

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "microservice"
  monitoring             = true
  vpc_security_group_ids = [module.ms_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[1]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              EOF

  tags = merge (
    local.common_labels,
    {
      Name = "microservice"
    }
  )
}
