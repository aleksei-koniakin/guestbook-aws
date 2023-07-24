data "aws_ecr_repository" "frontend_repo" {
  name = var.frontend_ecr
}

locals {
  frontend_container_defs = templatefile(
  "${path.module}/task-definitions/frontend.json",
  {
    image          = "${data.aws_ecr_repository.frontend_repo.repository_url}:${var.frontend_version}"
    container_name = local.frontend_container_name
    frontend_port  = local.frontend_port
    logs_group     = aws_cloudwatch_log_group.group.name
    logs_region    = data.aws_region.current.name
  }                                                       )
}

resource "aws_ecs_task_definition" "frontend_definition" {
  family                   = "${var.name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = local.frontend_container_defs
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.name}-frontend"
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  task_definition = aws_ecs_task_definition.frontend_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.public.ids

    security_groups = [
      aws_security_group.frontend.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = local.frontend_container_name
    container_port   = local.frontend_port
  }
}
