resource "aws_ecr_repository" "backend" {
  name = "guestbook-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "guestbook-frontend"
}
