resource "aws_s3_bucket" "picture_bucket" {
  bucket        = "jetbrains-guestbook-${var.name}"
  acl           = "public-read"
  force_destroy = true
}
