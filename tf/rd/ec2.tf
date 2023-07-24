data "aws_ami" "rd" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RD*"]
  }

  owners = ["self"]
}

resource "aws_key_pair" "key" {
  key_name_prefix = "rd_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "rd" {
  ami = data.aws_ami.rd.id
  instance_type = "t3a.xlarge"

  key_name = aws_key_pair.key.key_name
  subnet_id = data.aws_subnet.rd.id
  vpc_security_group_ids = [
    data.aws_security_group.sg.id
  ]

  root_block_device {
    volume_size = 100
  }

  tags = {
    "type" = "rd"
  }

  iam_instance_profile = "RDProfile"
}

output "hostname" {
  value = aws_instance.rd.public_dns
}
