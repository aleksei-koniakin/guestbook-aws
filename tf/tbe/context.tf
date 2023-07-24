
data "aws_region" "current" { }

data "aws_availability_zones" "zones" { }


data "aws_vpc" "current" {
  id = local.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    type = "service"
  }
}
