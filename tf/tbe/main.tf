provider "aws" {
  region = "us-west-2"
  // profile = "guestbook" // see the README.md for details
}

terraform {
  backend "s3" {
    key = "guestbook/tbe/terraform.tfstate"
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

variable "name" {
  default = "main"
}

locals {
  db_name = "tbe_prod"

  db_host = data.terraform_remote_state.shared.outputs.db_host
  db_port = data.terraform_remote_state.shared.outputs.db_port
  db_secret = data.terraform_remote_state.shared.outputs.db_secret
  db_username = data.terraform_remote_state.shared.outputs.db_username

  ecs_cluster_name = data.terraform_remote_state.shared.outputs.ecs_cluster

  dns_zone_name =  data.terraform_remote_state.shared.outputs.dns_zone_name
  dns_name = "tbe.${local.dns_zone_name}"

  vpc_id   = data.terraform_remote_state.shared.outputs.vpc_id
}
