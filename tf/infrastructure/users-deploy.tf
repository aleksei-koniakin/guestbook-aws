resource "aws_iam_user" "deploy_user_sts" {
  name = "deploy-user-sts"
}

output "teamcity_configuration_access_region" {
  value = data.aws_region.current.name
}

output "teamcity_configuration_role_arn" {
  value = aws_iam_role.deploy_user.arn
}

resource "aws_iam_user_policy_attachment" "deploy_user_sts" {
  user       = aws_iam_user.deploy_user_sts.name
  policy_arn = aws_iam_policy.deploy_user_sts.arn
}

resource "aws_iam_policy" "deploy_user_sts" {
  name_prefix = "deploy_user_sts_policy"
  policy = data.aws_iam_policy_document.deploy_user_sts.json
}

data "aws_iam_policy_document" "deploy_user_sts" {
  statement {
    effect    = "Allow"
    actions   = [
      "sts:AssumeRole"
    ]
    resources = [
      //In the real world
      aws_iam_role.deploy_user.arn
    ]
  }
}

resource "aws_iam_role" "deploy_user" {
  name = "TeamCityDeployRole"
  assume_role_policy = data.aws_iam_policy_document.admin-access-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "admin-access-policy" {
  role = aws_iam_role.deploy_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "admin-access-assume-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.deploy_user_sts.name}",
      ]
    }
  }
}
