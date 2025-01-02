
module "otel_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.1"


  role_name_prefix = "otel-sa"

  role_policy_arns = {
    "DescribeInstances" = module.otel-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:otel-node-opentelemetry-collector"]
    }
  }
}



module "otel-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.52.1"

  name_prefix = "otel"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "DescribeInstances",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "eks:DescribeCluster",
          "ec2:DescribeTags",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}
