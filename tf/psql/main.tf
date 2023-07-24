
variable "db_name" { type = string }
variable "db_host" { type = string }
variable "db_port" { type = string }
variable "db_username" { type = string }
variable "db_secret" { type = string }

variable "sql" { type = string }

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_secret
}

resource "local_file" "local" {
  filename = "${local.temp_dir}/${local.temp_file}"
  content = var.sql
}

locals {
  temp_dir = abspath("${path.root}/.terraform")
  temp_file = "sql-${sha256(var.sql)}.sql"
}

resource "null_resource" "configure_database" {
  triggers = {
    sql = sha512(var.sql)
    command = sha512(local.command)
  }
  
  provisioner "local-exec" {
    command = local.command
  }
}

locals {
  command = "docker run --rm -v ${local.temp_dir}:/sql:ro ${join(" ", local.docker_env_args)} postgres:13 ${join(" ", local.docker_run_args)}"

  docker_env_args = [
    "-e",
    "PGPASSWORD=${data.aws_secretsmanager_secret_version.db_password.secret_string}",
  ]

  docker_run_args = [
    "psql",
    "-h", var.db_host,
    "-p", var.db_port,
    "-U", var.db_username,
    "-d", var.db_name,
    "-a",
    "-f",
    "/sql/${local.temp_file}"
  ]


}
