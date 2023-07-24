resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
}


output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}
