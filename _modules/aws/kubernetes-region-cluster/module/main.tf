provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
# data "aws_ecrpublic_authorization_token" "public_token" {
#   # provider = aws.virginia
# }

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
  #   registry {
  #     url      = "oci://ghcr.io"
  #     username = "_PAT_"
  #     password = var.GITHUB_PAT
  #   }
  #   registry {
  #     url      = "oci://public.ecr.aws"
  #     password = data.aws_ecrpublic_authorization_token.public_token.password
  #     username = data.aws_ecrpublic_authorization_token.public_token.user_name
  #   }
}

provider "kubectl" {
  load_config_file       = false
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}


data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {}
# data "aws_partition" "current" {}
# locals {

#   tags = {}
# }
