
data "aws_ecr_repository" "backend_repo" {
  name = var.backend_ecr
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_secret
}

locals {
  db_name = "guestbook_${var.name}"
}

variable "db_host" { type = string }
variable "db_port" { type = string }
variable "db_username" { type = string }
variable "db_secret" { type = string }

locals {
  backend_container_defs = templatefile(
  "${path.module}/task-definitions/backend.json",
  {
    image          = "${data.aws_ecr_repository.backend_repo.repository_url}:${var.backend_version}"
    container_name = local.backend_container_name
    backend_port   = local.backend_port
    logs_group     = aws_cloudwatch_log_group.group.name
    logs_region    = data.aws_region.current.name
    db_host        = var.db_host
    db_port        = var.db_port
    db_name        = local.db_name
    db_user        = var.db_username
    db_password    = data.aws_secretsmanager_secret_version.db_password.secret_string
    region         = data.aws_region.current.name
    picture_bucket = aws_s3_bucket.picture_bucket.bucket
  })
}

resource "aws_ecs_task_definition" "backend_definition" {
  family                   = "${var.name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = local.backend_container_defs
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_backend_service.arn
}

resource "aws_ecs_service" "backend_service" {
  name            = "${var.name}-backend"
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  task_definition = aws_ecs_task_definition.backend_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  depends_on = [module.psql_db, module.psql_schema]

  network_configuration {
    subnets = data.aws_subnets.public.ids

    security_groups = [
      aws_security_group.backend.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = local.backend_container_name
    container_port   = local.backend_port
  }
}
