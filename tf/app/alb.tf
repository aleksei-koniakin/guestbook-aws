resource "aws_lb" "lb" {
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.load_balancer.id]
  subnets         = data.aws_subnets.public.ids
}

data "aws_route53_zone" "current" {
  name = var.dns_zone
}

resource "aws_route53_record" "lb" {
  name    = var.dns_name
  type    = "A"
  zone_id = data.aws_route53_zone.current.id

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "guestbook-backend-${var.name}"
  protocol    = "HTTP"
  port        = local.backend_port
  vpc_id      = var.vpc_id
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

    path = "/health"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "guestbook-frontend-${var.name}"
  protocol    = "HTTP"
  port        = local.frontend_port
  vpc_id      = var.vpc_id
  target_type = "ip"
}

module "certificate" {
  source  = "git::https://github.com/jetbrains-infra/terraform-aws-acm-certificate?ref=v0.4.0"
  name    = "test_certificate"
  region  = data.aws_region.current.name
  aliases = [
    {
      hostname = var.dns_name,
      zone_id  = data.aws_route53_zone.current.zone_id
    }
  ]
}

resource "aws_lb_listener" "guestbook" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "guestbook80" {
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

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.guestbook.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern {
      values = [
        "/entries*",
        "/health*",
      ]
    }
  }
}
