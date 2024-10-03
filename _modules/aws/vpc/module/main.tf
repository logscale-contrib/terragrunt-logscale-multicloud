
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_ipv6_prefixes                    = var.public_subnet_ipv6_prefixes
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = var.private_subnet_ipv6_prefixes
  private_subnet_assign_ipv6_address_on_creation = true


  public_subnet_tags = {
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
    "karpenter.sh/discovery"            = "${var.name}"
  }


  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 1

}

module "vpc_vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.13.0"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${var.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "s3-vpc-endpoint" }
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ecs-vpc-endpoint" }
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ecs-tel-vpc-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      policy     = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags       = { Name = "ecr-api-vpc-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      policy     = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags       = { Name = "ecr-dkr-vpc-endpoint" }
    },
    sns = {
      service             = "sns"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "sqs-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ssm-vpc-endpoint" }
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ssmmessages-vpc-endpoint" }
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ec2-vpc-endpoint" }
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "ec2messages-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "kms-vpc-endpoint" }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      # ip_address_type     = "dualstack"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "logsfa-vpc-endpoint" }
    },
  }

}



data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}
