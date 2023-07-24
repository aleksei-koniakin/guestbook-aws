provider "aws" {
  region = "us-west-2"
  // profile = "guestbook" // see the README.md for details
}

terraform {
  backend "s3" {
    key = "guestbook/prod/terraform.tfstate"
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
  dns_zone_name = data.terraform_remote_state.shared.outputs.dns_zone_name
}

module "app" {
  source = "../app"

  name     = terraform.workspace == "default" ? "prod" : terraform.workspace
  dns_name = terraform.workspace == "default" ? local.dns_zone_name : "${terraform.workspace}.${local.dns_zone_name}"

  dns_zone = local.dns_zone_name
  vpc_id   = data.terraform_remote_state.shared.outputs.vpc_id

  backend_ecr = data.terraform_remote_state.shared.outputs.backend_ecr
  frontend_ecr = data.terraform_remote_state.shared.outputs.frontend_ecr

  backend_version = var.backend_version
  frontend_version = var.frontend_version

  ecs_cluster_name = data.terraform_remote_state.shared.outputs.ecs_cluster

  db_host = data.terraform_remote_state.shared.outputs.db_host
  db_port = data.terraform_remote_state.shared.outputs.db_port
  db_secret = data.terraform_remote_state.shared.outputs.db_secret
  db_username = data.terraform_remote_state.shared.outputs.db_username
}

variable "backend_version" {}
variable "frontend_version" {}
