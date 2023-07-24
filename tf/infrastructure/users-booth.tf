resource "aws_iam_user" "booth_user" {
  name = "booth-user"
}

resource "aws_iam_user_policy_attachment" "booth_user_viewOnly" {
  user        = aws_iam_user.booth_user.name
  policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_policy_attachment" "booth_user_rds_secret" {
  user        = aws_iam_user.booth_user.name
  policy_arn  = aws_iam_policy.booth_user_rds_secret.arn
}

resource "aws_iam_policy" "booth_user_rds_secret" {
  name_prefix = "booth_user_rds_secret"
  policy      = data.aws_iam_policy_document.booth_user_rds_secret.json
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "booth_user_rds_secret" {
  statement {
    effect    = "Allow"
    actions   = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.db_password_json.name}",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "*"
    ]
  }
}
