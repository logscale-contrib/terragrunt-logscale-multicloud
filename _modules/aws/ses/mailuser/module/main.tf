

resource "aws_iam_policy" "send_mail" {
  name   = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"
  policy = data.aws_iam_policy_document.send_mail.json
}

locals {
  arnforraw = var.arn_raw
}
data "aws_iam_policy_document" "send_mail" {
  statement {
    actions = ["ses:SendRawEmail"]
    resources = [
      # aws_sesv2_email_identity.main.arn,
      local.arnforraw,
      var.aws_sesv2_configuration_set_arn
    ]
  }

}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module "iam_ses_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.52.1"

  name = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_reset_required       = false
  policy_arns = [
    aws_iam_policy.send_mail.arn
  ]
}
