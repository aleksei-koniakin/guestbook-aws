data "aws_subnet" "rd" {
  filter {
    name = "tag:type"
    values = ["rd"]
  }
}

data "aws_security_group" "sg" {
  name = "RemoteDevelopment"
}