terraform {
  backend "s3" {
    bucket  = "jumia-phone-validator"
    key     = "remote/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}