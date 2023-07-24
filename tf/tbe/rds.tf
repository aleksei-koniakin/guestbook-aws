
module "psql_db" {
  source = "../psql"

  db_host = local.db_host
  db_name = "postgres"
  db_port = local.db_port
  db_secret = local.db_secret
  db_username = local.db_username
  sql = " CREATE DATABASE ${local.db_name}; "
}
