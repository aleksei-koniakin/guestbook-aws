output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "backend_ecr" {
  value = aws_ecr_repository.backend.name
}

output "frontend_ecr" {
  value = aws_ecr_repository.frontend.name
}

output "db_sg_id" {
  value = aws_security_group.database.id
}

output "database_host" {
  value = aws_route53_record.db.fqdn
}
