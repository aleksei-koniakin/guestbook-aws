resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.bastion_ami.id
  instance_type = "t3.nano"

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.id

  //TODO: keep the host SSH key stable! 
  user_data = <<-EOF
#!/bin/bash
echo "s3://${aws_s3_bucket.bastion_keys.id}/" >> /etc/keybucket
chmod 644 /etc/keybucket
EOF

  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.bastion_subnet.id

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_s3_bucket" "bastion_keys" {
  bucket = "jetbrains-guestbook-bastion-keys"
}

resource "aws_s3_bucket_acl" "tbe" {
  bucket = aws_s3_bucket.bastion_keys.id
  acl    = "private"
}

data "aws_iam_policy_document" "bastion_host" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.bastion_keys.arn,
      "${aws_s3_bucket.bastion_keys.arn}/*",
    ]
  }
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

resource "aws_iam_role" "bastion_role" {
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  name               = "GuestbookBastionRole"
}

resource "aws_iam_role_policy" "bastion_policy" {
  policy = data.aws_iam_policy_document.bastion_host.json
  role   = aws_iam_role.bastion_role.id
}

resource "aws_iam_instance_profile" "bastion_profile" {
  role = aws_iam_role.bastion_role.id
  name = "GuestbookBastionProfile"
}

data "aws_ami" "bastion_ami" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["Bastion*"]
  }
}

resource "aws_security_group" "bastion" {
  name = "Bastion"
  vpc_id = local.vpc_id

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

resource "aws_subnet" "bastion_subnet" {
  cidr_block = "10.0.210.0/28"
  vpc_id     = local.vpc_id
  map_public_ip_on_launch = true

  tags = {
    Name = "Bastion Subnet"
  }
}

resource "aws_route53_record" "bastion" {
  name    = "bastion"
  type    = "A"
  zone_id = data.aws_route53_zone.dns.zone_id
  ttl     = 5
  records = [aws_instance.bastion_host.public_ip]
}
