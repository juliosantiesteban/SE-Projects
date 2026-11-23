# --- GitHub OIDC trust: lets GitHub Actions assume a role without stored keys ---
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "ci_trust" {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:juliosantiesteban@83293872/SE-Projects@1446364078:pull_request"]
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "${module.naming.prefix}-ci"
  assume_role_policy = data.aws_iam_policy_document.ci_trust.json
}

# Read-only for now; enough for terraform plan. Tighten or extend in Day 10.
resource "aws_iam_role_policy_attachment" "ci_readonly" {
  role       = aws_iam_role.ci.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# --- Secrets Manager: the secret container only, no real value in code ---
resource "aws_secretsmanager_secret" "demo" {
    #checkov:skip=CKV_AWS_149:Demo secret; the default AWS-managed key is fine and a CMK adds cost
  #checkov:skip=CKV2_AWS_57:Demo secret with no consumer; rotation needs a Lambda and adds cost
  name                    = "${module.naming.prefix}/demo-secret"
  description             = "Placeholder secret for the SE portfolio"
  recovery_window_in_days = 0
}

# --- Budget alert: $5/month, email at 80% actual and 100% forecast ---
resource "aws_budgets_budget" "monthly" {
  name         = "${module.naming.prefix}-monthly"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

output "ci_role_arn" { value = aws_iam_role.ci.arn }
output "secret_name" { value = aws_secretsmanager_secret.demo.name }