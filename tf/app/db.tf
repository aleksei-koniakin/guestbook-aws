
module "psql_db" {
  source = "../psql"

  db_host = var.db_host
  db_name = "postgres"
  db_port = var.db_port
  db_secret = var.db_secret
  db_username = var.db_username
  sql = <<EEE

  CREATE DATABASE ${local.db_name};

EEE
}


module "psql_schema" {
  source = "../psql"

  depends_on = [module.psql_db]

  db_host = var.db_host
  db_name = local.db_name
  db_port = var.db_port
  db_secret = var.db_secret
  db_username = var.db_username
  sql = file("${path.root}/../../database/schema.sql")
}
