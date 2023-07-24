
locals {
  backend_port            = 8080
  backend_container_name  = "backend"
  backend_health_check    = "/entries"

  frontend_port           = 80
  frontend_container_name = "frontend"
  frontend_health_check   = "/"
}

resource "aws_cloudwatch_log_group" "group" {
  name              = "guestbook/${var.name}"
  retention_in_days = 14
}
