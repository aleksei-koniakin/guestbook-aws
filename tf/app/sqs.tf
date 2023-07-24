resource "aws_sqs_queue" "queue" {
  name                       = "GuestbookQueue${var.name}"
  visibility_timeout_seconds = 15
}

data "aws_iam_policy_document" "sqs_for_backend" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}

resource "aws_iam_role_policy" "sqs_for_backend" {
  name   = "GuestbookQueue${var.name}"
  policy = data.aws_iam_policy_document.sqs_for_backend.json
  role   = aws_iam_role.ecs_backend_service.id
}
