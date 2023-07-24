

resource "aws_s3_bucket" "tbe" {
  bucket = "tbe-prod"
}

resource "aws_s3_bucket_acl" "tbe" {
  bucket = aws_s3_bucket.tbe.id
  acl    = "private"
}

