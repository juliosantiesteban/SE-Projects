locals {
  github_repo_sub = "repo:juliosantiesteban@83293872/SE-Projects@1446364078"
}

# Plan role: read the state and take the lock
data "aws_iam_policy_document" "plan_state_access" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.sa.arn]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sa.arn}/aws/dev.tfstate"]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.sa.arn}/aws/dev.tfstate.tflock"]
  }
}

resource "aws_iam_role_policy" "ci_state" {
  name   = "terraform-state-access"
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.plan_state_access.json
}

# Apply role: only usable from the GitHub "production" environment
data "aws_iam_policy_document" "apply_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${local.github_repo_sub}:environment:production"]
    }
  }
}

resource "aws_iam_role" "apply" {
  name               = "${module.naming.prefix}-apply"
  assume_role_policy = data.aws_iam_policy_document.apply_trust.json
}

# Broad on purpose for a personal sandbox. The real protection is the trust
# policy plus the approval gate. Tighten this later.
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "plan_role_arn" { value = aws_iam_role.ci.arn }
output "apply_role_arn" { value = aws_iam_role.apply.arn }