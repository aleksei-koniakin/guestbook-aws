resource "aws_subnet" "agent_subnet" {
  cidr_block              = "10.0.250.0/24"
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "Teamcity Agent Subnet"
  }
}

resource "aws_route_table" "agent_subnet_route_table" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "outbound" {
  route_table_id         = aws_route_table.agent_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "agent_subnet" {
  route_table_id = aws_route_table.agent_subnet_route_table.id
  subnet_id      = aws_subnet.agent_subnet.id
}

resource "aws_security_group" "tc_agent" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "tc-agent"

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "teamcity_agent_sg" {
  value = aws_security_group.tc_agent.id
}

output "teamcity_agent_subnet" {
  value = aws_subnet.agent_subnet.id
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "teamcity_agent_role" {
  name = "GuestbookTeamCityAgentRole"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role" "teamcity_deployment_role" {
  name = "GuestbookTeamCityDeploymentAgentRole"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "teamcity_deployment_policy" {
  statement {
    actions = [
      "ecs:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "teamcity_ecs_policy" {
  policy = data.aws_iam_policy_document.teamcity_deployment_policy.json
}

resource "aws_iam_role_policy_attachment" "teamcity_deployment_policy" {
  role       = aws_iam_role.teamcity_deployment_role.name
  policy_arn = aws_iam_policy.teamcity_ecs_policy.arn
}

resource "aws_iam_instance_profile" "teamcity_agent_instance_profile" {
  name = "GuestbookTeamCityAgentProfile"
  role = aws_iam_role.teamcity_agent_role.name
}

resource "aws_iam_role" "teamcity_server_role" {
  name = "GuestbookTeamCityServerRole"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "teamcity_server_instance_profile" {
  name = "GuestbookTeamCityServerProfile"
  role = aws_iam_role.teamcity_server_role.name
}


data "aws_iam_policy_document" "ecr_teamcity_agent" {
  statement {
    actions = [
      "ecr:*",
      "cloudtrail:LookupEvents"
    ]

    resources = [
      aws_ecr_repository.backend.arn,
      aws_ecr_repository.frontend.arn,
    ]
  }
}


data "aws_iam_policy_document" "teamcity_server" {
  statement {
    actions = [
      "ec2:*",
      "iam:PassRole",
      "iam:ListInstanceProfiles",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "teamcity_agent_role_ecr" {
  policy = data.aws_iam_policy_document.ecr_teamcity_agent.json
  role   = aws_iam_role.teamcity_agent_role.id
}

resource "aws_iam_role_policy" "teamcity_server_role_ecr" {
  policy = data.aws_iam_policy_document.ecr_teamcity_agent.json
  role   = aws_iam_role.teamcity_server_role.id
}

resource "aws_iam_role_policy" "teamcity_server_role_iam" {
  policy = data.aws_iam_policy_document.teamcity_server.json
  role   = aws_iam_role.teamcity_server_role.id
}
