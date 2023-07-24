resource "aws_security_group" "rd" {
  name = "RemoteDevelopment"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    protocol    = "TCP"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "rd" {
  cidr_block = "10.0.50.0/24"
  vpc_id     = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    type = "rd"
  }
}

data "aws_iam_policy_document" "rd_policy" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "rd_role" {
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  name               = "RDRole"
}

resource "aws_iam_role_policy" "rd_policy" {
  policy = data.aws_iam_policy_document.rd_policy.json
  role   = aws_iam_role.rd_role.id
}

resource "aws_iam_instance_profile" "rd_profile" {
  role = aws_iam_role.rd_role.id
  name = "RDProfile"
}
