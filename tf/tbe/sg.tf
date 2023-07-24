
resource "aws_security_group" "tbe" {
  name = "tbe-${var.name}"
  vpc_id = local.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = local.backend_port
    to_port         = local.backend_port
    security_groups = [aws_security_group.load_balancer.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_security_group_rule" "backend_to_db" {
#  type                     = "ingress"
#  protocol                 = "tcp"
#  from_port                = 5432
#  to_port                  = 5432
#  security_group_id        = var.db_sg_id
#  source_security_group_id = aws_security_group.backend.id
#}

resource "aws_security_group" "load_balancer" {
  name = "load-balancer-${var.name}"
  vpc_id = data.aws_vpc.current.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
