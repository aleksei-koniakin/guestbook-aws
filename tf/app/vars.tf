variable "name" { type = string }
variable "vpc_id" { type = string }
variable "dns_name" { type = string }
variable "dns_zone" { type = string }
variable "backend_version" { type = string }
variable "backend_ecr" { type = string }
variable "frontend_version" { type = string }
variable "frontend_ecr" { type = string }
variable "ecs_cluster_name" { type = string }



data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster_name
}
