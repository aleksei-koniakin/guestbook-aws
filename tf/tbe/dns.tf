module "certificate" {
  source  = "git::https://github.com/jetbrains-infra/terraform-aws-acm-certificate?ref=v0.4.0"
  name    = "test_certificate"
  region  = data.aws_region.current.name
  aliases = [
    {
      hostname = local.dns_name,
      zone_id  = data.aws_route53_zone.current.zone_id
    }
  ]
}

data "aws_route53_zone" "current" {
  name = local.dns_zone_name
}

resource "aws_route53_record" "lb" {
  name    = local.dns_name
  type    = "A"
  zone_id = data.aws_route53_zone.current.id

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
