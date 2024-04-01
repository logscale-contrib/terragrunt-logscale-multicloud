module "ingest-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.37.2"

  create_role       = true
  role_name_prefix  = "${local.namespace}_${var.service_account}_ingest"
  role_requires_mfa = false

  trusted_role_arns = [
    module.irsa.iam_role_arn,
  ]
  custom_role_policy_arns = [
    module.iam_iam-assume_ingest-actor.arn
  ]
}

module "ingest-role-actor" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.37.2"

  create_role       = true
  role_name_prefix  = "${local.namespace}_${var.service_account}_actor"
  role_requires_mfa = false

  # trusted_role_arns = [
  #   module.ingest-role.iam_role_arn,
  # ]
  # role_sts_externalid = "SINGLE_ORGANIZATION_ID/*"

  custom_role_policy_arns = [
    module.iam_iam-policy-s3log.arn
  ]

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.custom_trust_policy.json

}


data "aws_iam_policy_document" "custom_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringLike"
      variable = "sts:ExternalId"
      values   = ["SINGLE_ORGANIZATION_ID/*"]
    }


    principals {
      type        = "AWS"
      identifiers = [module.ingest-role.iam_role_arn]
    }
  }
}
module "iam_iam-assume_ingest-actor" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.2"

  name_prefix = "${local.namespace}_${var.service_account}-assume-ingest-base"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          module.ingest-role-actor.iam_role_arn
        ]
      },
    ]
  })
}


module "iam_iam-policy-s3log" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.2"

  name_prefix = "${local.namespace}_${var.service_account}-ingest-s3"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "${var.regional_logs_bucket_arn}/*"
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          var.regional_logs_bucket_arn
        ]
      }
    ]
  })
}
