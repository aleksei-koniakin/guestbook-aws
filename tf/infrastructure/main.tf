provider "aws" {
  region = "us-west-2"
  // profile = "guestbook" // see the README.md for details, `export AWS_PROFILE=guestbook`
}

terraform {
  backend "s3" {
    key = "guestbook/infrastructure/terraform.tfstate"
    bucket          = "reinvent22-guestbook-tfstate"
    region          = "us-west-2"
    dynamodb_table  = "reinvent-guestbook-tf-locks"
    encrypt         = true
  }
}

#
# Uncomment that if you need to create the state bucket
# with Terraform
#
#
#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "reinvent22-guestbook-tfstate"
#
#  # Prevent accidental deletion of this S3 bucket
#  lifecycle {
#    prevent_destroy = true
#  }
#
#  # Enable versioning so we can see the full revision history of our
#  # state files
#  versioning {
#    enabled = true
#  }
#
#  # Enable server-side encryption by default
#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#}
#