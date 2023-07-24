
resource "aws_route53_zone" "main_zone" {
  name = "guestbook.teamcity.com"
}


resource "aws_route53_record" "db" {
  name    = "db"
  type    = "CNAME"
  zone_id = aws_route53_zone.main_zone.id
  ttl     = 30
  records = [aws_db_instance.guestbook.address]
}

output "dns_zone_name" {
  value = aws_route53_zone.main_zone.name
}
