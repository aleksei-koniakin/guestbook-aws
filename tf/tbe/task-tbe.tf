
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = local.db_secret
}

variable "tbe_version" {
  default = "1.0.3046"
}

resource "aws_cloudwatch_log_group" "group" {
  name              = "tbe-${var.name}"
  retention_in_days = 14
}

locals {
  backend_container_name = "tbe"
  backend_port = local.tbe_container_port

  backend_container_defs = templatefile(
  "${path.module}/task-definitions/tbe.json",
  {
    image          = "${aws_ecr_repository.tbe.repository_url}:${var.tbe_version}"
    container_name = local.backend_container_name
    backend_port   = local.backend_port
    logs_group     = aws_cloudwatch_log_group.group.name
    logs_region    = data.aws_region.current.name
    db_host        = local.db_host
    db_port        = local.db_port
    db_name        = local.db_name
    db_user        = local.db_username
    db_password_arn= data.aws_secretsmanager_secret_version.db_password.arn
    oauth_secret_arn= aws_secretsmanager_secret.tbe-oauth.arn
    region         = data.aws_region.current.name
    tbe_bucket = aws_s3_bucket.tbe.bucket
  })
}

resource "aws_secretsmanager_secret" "tbe-oauth" {
  name_prefix = "tbe-oauth-service"
  //you should define that secret value via AWS Console
}

resource "aws_ecs_task_definition" "backend_definition" {
  family                   = "tbe-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = local.backend_container_defs
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tbe_task.arn
}

resource "aws_ecs_service" "backend_service" {
  name            = "tbe-${var.name}"
  cluster         = local.ecs_cluster_name
  task_definition = aws_ecs_task_definition.backend_definition.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  depends_on = [module.psql_db]

  network_configuration {
    subnets = data.aws_subnets.public.ids

    security_groups = [
      aws_security_group.tbe.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tbe.arn
    container_name   = local.backend_container_name
    container_port   = local.backend_port
  }
}
