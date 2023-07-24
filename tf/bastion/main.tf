provider "aws" {
  region = "us-west-2"
  // profile = "guestbook" // see the README.md for details
}

terraform {
  backend "s3" {
    key = "guestbook/bastion/terraform.tfstate"
    bucket          = "reinvent22-guestbook-tfstate"
    region          = "us-west-2"
    dynamodb_table  = "reinvent-guestbook-tf-locks"
    encrypt         = true
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    key    = "guestbook/infrastructure/terraform.tfstate"
    bucket = "reinvent22-guestbook-tfstate"
    region = "us-west-2"
  }
}


locals {
  vpc_id = data.terraform_remote_state.shared.outputs.vpc_id
  dns_zone = "guestbook.teamcity.com"
}

data "aws_route53_zone" "dns" {
   name = local.dns_zone
}
