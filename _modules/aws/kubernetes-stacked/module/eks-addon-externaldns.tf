module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "externaldns"
  role_path        = var.iam_role_path

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["externaldns:externaldns"]
    }
  }

}