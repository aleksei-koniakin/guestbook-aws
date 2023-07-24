
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Guestbook"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

data "aws_availability_zones" "zones" {
}

resource "aws_subnet" "db_subnets" {
  count                   = length(data.aws_availability_zones.zones.names)
  cidr_block              = cidrsubnet("10.0.195.0/24", 4, count.index)
  availability_zone       = data.aws_availability_zones.zones.names[count.index]
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    type = "db"
    Name = "Database Subnet ${count.index}"
  }
}

resource "aws_subnet" "ecs_subnets" {
  count      = length(data.aws_availability_zones.zones.names)
  cidr_block = cidrsubnet("10.0.16.0/20", 4, count.index)
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone       = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    type = "service"
    Name = "ECS Subnet ${count.index}"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "db_outbound" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_main_route_table_association" "main_route_table" {
  route_table_id = aws_route_table.main_route_table.id
  vpc_id         = aws_vpc.main_vpc.id
}
