data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecr_for_ecs" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.tbe-oauth.arn,
      data.aws_secretsmanager_secret_version.db_password.arn,
    ]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "TbeExecRole-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_execution" {
  policy = data.aws_iam_policy_document.ecr_for_ecs.json
  role   = aws_iam_role.ecs_execution_role.id
}

resource "aws_iam_role_policy_attachment" "managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ecs_tbe_task.id
}

resource "aws_iam_role" "ecs_tbe_task" {
  name               = "TbeTaskRole-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "s3_for_backend" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.tbe.arn,
      "${aws_s3_bucket.tbe.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_backend_s3" {
  policy = data.aws_iam_policy_document.s3_for_backend.json
  role   = aws_iam_role.ecs_tbe_task.id
}
