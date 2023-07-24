resource "aws_lb" "lb" {
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.load_balancer.id]
  subnets         = data.aws_subnets.public.ids
}

locals {
  tbe_container_port = 8080
}

resource "aws_lb_target_group" "tbe" {
  name        = "tbe-${var.name}"
  protocol    = "HTTP"
  port        = local.tbe_container_port
  vpc_id      = local.vpc_id
  target_type = "ip"

  // Default is 300 seconds of 'DRAINING', this reduces it to 5 seconds
  deregistration_delay = 5

  health_check {
    // AWS restriction:
    // Health checks must be enabled for target groups with target type 'ip'
    enabled = true

    // Set healthy threshold to the minimum
    healthy_threshold = 2

    // Check more frequently to come online more quickly
    interval = 11

    // AWS logic says timeout must be < interval
    // This means the app needs to come alive in 20 seconds, or we'll boot loop.
    timeout = 10

    path = "/actuator/health"
  }
}

resource "aws_lb_listener" "tbe" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tbe.arn
  }
}

resource "aws_lb_listener" "tbe80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
