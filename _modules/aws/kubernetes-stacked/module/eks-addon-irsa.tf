resource "kubernetes_config_map" "cluster_vars" {
  depends_on = [helm_release.flux2]
  metadata {
    name      = "clustervars"
    namespace = "flux-system"
  }

  data = {
    aws_eks_cluster_name = var.cluster_name
    aws_region           = var.cluster_region
    aws_arn_efs          = module.efs_csi_irsa.iam_role_arn
    aws_arn_ebs          = module.ebs_csi_irsa.iam_role_arn
    aws_arn_alb          = module.ing_alb_irsa.iam_role_arn
    aws_arn_keda         = module.keda_irsa.iam_role_arn
    aws_arn_edns         = module.edns_irsa.iam_role_arn
  }

}

module "ing_alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "alb"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "ebs_csi"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix


  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

}

module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "efs_csi"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

}


module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "keda-operator"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix


  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }

}

module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "external-dns"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }

}
