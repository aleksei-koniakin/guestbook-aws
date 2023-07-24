resource "aws_db_instance" "guestbook" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = "db.t3.medium"
  username               = "jetbrains"
  password               = aws_secretsmanager_secret_version.db_password.secret_string
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = true
  iam_database_authentication_enabled = true
  apply_immediately = true
#  db_name = "guestbook_db"
  identifier = "guestbook"
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "db_subnets" {
  subnet_ids = aws_subnet.db_subnets.*.id
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "guestbook/db/master"
  recovery_window_in_days = 10
}

resource "aws_secretsmanager_secret" "db_password_json" {
  name                    = "guestbook/db/master_json"
  recovery_window_in_days = 10
}


output "db_public_host" { value = aws_route53_record.db.fqdn }
output "db_host"        { value = aws_db_instance.guestbook.address }
output "db_port"        { value = aws_db_instance.guestbook.port }
output "db_username"    { value = aws_db_instance.guestbook.username }
output "db_secret"      { value = aws_secretsmanager_secret.db_password.name }
output "db_secret_json" { value = aws_secretsmanager_secret.db_password_json.name }

resource "random_password" "db_password" {
  length  = 20
  special = false # RDS is limited, and this is a demo app
  keepers = {
    version = 1234
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret_version" "db_password_json" {
  secret_id     = aws_secretsmanager_secret.db_password_json.id
  secret_string = jsonencode({
    "database"    = aws_db_instance.guestbook.db_name
    "engine"      = aws_db_instance.guestbook.engine
    "public_host" = aws_route53_record.db.fqdn,
    "host"        = aws_db_instance.guestbook.address,
    "port"        = aws_db_instance.guestbook.port,
    "username"    = aws_db_instance.guestbook.username
    "password"    = aws_secretsmanager_secret_version.db_password.secret_string
  })
}

resource "aws_security_group" "database" {
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = "Guestbook-RDS"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.database.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_to_db" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  security_group_id        = aws_security_group.database.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "agent_to_db" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.tc_agent.id
}

module "psql" {

  depends_on = [aws_secretsmanager_secret.db_password]

  source = "../psql"

  db_host = aws_db_instance.guestbook.address
  db_name = aws_db_instance.guestbook.name
  db_port = aws_db_instance.guestbook.port
  db_secret = aws_secretsmanager_secret.db_password.name
  db_username = aws_db_instance.guestbook.username
  sql = <<EOT
    CREATE USER iamuser WITH LOGIN;
    GRANT rds_iam TO iamuser;
    GRANT rds_superuser to iamuser;
EOT
}
