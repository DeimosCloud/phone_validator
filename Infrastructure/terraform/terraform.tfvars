region               = "eu-west-1"
environment          = "production"
vpc_cidr_block       = "10.10.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_name             = "Phone_validator_vpc"
private_subnets      = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
public_subnets       = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
database_subnets     = ["10.10.8.0/24", "10.10.10.0/24"]
linux_ami            = "ami-0fb2f0b847d44d4f0"
linux_instance_type  = "t3.medium"
db_name              = "jumia_phone_validator"
db_engine_version    = "14.7"
db_engine            = "postgres"
db_instance_class    = "db.t3.large"
db_allocated_storage = 20
db_username          = "jumia"
cluster_name         = "jumia-cluster"
backend_name         = "validator-bkend"
frontend_name        = "validator-ftend"



