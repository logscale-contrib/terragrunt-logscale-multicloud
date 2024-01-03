
################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {

    kube-proxy = {
      enabled        = true
      before_compute = true
      # most_recent    = true
      addon_version = "v1.28.4-eksbuild.1"
    }

    vpc-cni = {
      enabled = true
      # most_recent              = true
      before_compute           = true
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      addon_version            = "v1.15.4-eksbuild.1"
      configuration_values = jsonencode({
        nodeAgent = {

          enableCloudWatchLogs = "true"
          healthProbeBindAddr  = "8163"
          metricsBindAddr      = "8162"
        }
        # env = {
        #   # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
        #   ENABLE_PREFIX_DELEGATION = "true"
        #   WARM_PREFIX_TARGET       = "1"
        # }
      })
    }

    coredns = {
      # most_recent = true
      addon_version     = "v1.10.1-eksbuild.6"
      resolve_conflicts = "OVERWRITE"
      configuration_values = jsonencode({
        replicaCount = 3
        # computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        podDisruptionBudget = {
          enabled        = true
          maxUnavailable = 1
        }
        topologySpreadConstraints = [
          {
            maxSkew : 1
            topologyKey : "kubernetes.io/hostname"
            whenUnsatisfiable : "DoNotSchedule"
            labelSelector : {
              matchLabels : {
                "k8s-app" : "kube-dns"
              }
            }
            matchLabelKeys : [
              "pod-template-hash"
            ]
          },
          {
            maxSkew : 1
            topologyKey : "topology.kubernetes.io/zone"
            whenUnsatisfiable : "ScheduleAnyway"
            labelSelector : {
              matchLabels : {
                "k8s-app" : "kube-dns"
              }
            }
            matchLabelKeys : [
              "pod-template-hash"
            ]
          }
        ]

        resources = {
          limits = {
            cpu = "1"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "1"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }

    snapshot-controller = {}

    "aws-ebs-csi-driver" = {
      enabled = true
      # most_recent              = true
      # before_compute           = true
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.iam_eks_role_ebs.iam_role_arn
      addon_version            = "v1.26.0-eksbuild.1"
      # configuration_values = jsonencode({
      #   nodeAgent = {

      #     enableCloudWatchLogs = "true"
      #     healthProbeBindAddr  = "8163"
      #     metricsBindAddr      = "8162"
      #   }
      #   # env = {
      #   #   # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      #   #   ENABLE_PREFIX_DELEGATION = "true"
      #   #   WARM_PREFIX_TARGET       = "1"
      #   # }
      # })
    }

    "aws-efs-csi-driver" = {
      enabled = true
      # most_recent              = true
      # before_compute           = true
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.iam_eks_role_efs.iam_role_arn
      addon_version            = "v1.7.1-eksbuild.1"
      # configuration_values = jsonencode({
      #   nodeAgent = {

      #     enableCloudWatchLogs = "true"
      #     healthProbeBindAddr  = "8163"
      #     metricsBindAddr      = "8162"
      #   }
      #   # env = {
      #   #   # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      #   #   ENABLE_PREFIX_DELEGATION = "true"
      #   #   WARM_PREFIX_TARGET       = "1"
      #   # }
      # })
    }

    "eks-pod-identity-agent" = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.0.0-eksbuild.1"
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = true


  enable_irsa = true
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  # manage_aws_auth 
  aws_auth_roles = concat(
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    [{
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
      }
    ],
    var.additional_aws_auth_roles
  )

  aws_auth_users = [
    # {
    #   userarn  = data.aws_caller_identity.current.arn
    #   username = "admin-caller"
    #   groups   = ["system:masters"]
    # },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      username = "admin-aws-root"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]

  # fargate_profile_defaults = {
  #   iam_role_additional_policies = {
  #     additional = aws_iam_policy.additional.arn
  #   }
  # }

  fargate_profiles = {

    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
  }

  eks_managed_node_group_defaults = {
    # We are using the IRSA created below for permissions
    # However, we have to provision a new cluster with the policy attached FIRST
    # before we can disable. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the new cluster
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    # Default node group - as provided by AWS EKS
    "system-arm64" = {
      min_size     = 1
      max_size     = 7
      desired_size = 1

      instance_types = ["m7g.large"]
      labels = {
        computeClass = "general"
        storageClass = "network"
      }

      taints = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "PREFER_NO_SCHEDULE"
        }
      ]

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_ARM_64"
      platform = "bottlerocket"
    }

    "system-x86" = {
      min_size     = 1
      max_size     = 7
      desired_size = 1

      instance_types = ["m7i-flex.large"]
      labels = {
        computeClass = "general"
        storageClass = "network"
      }

      taints = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "PREFER_NO_SCHEDULE"
        }
      ]

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
    "aws-alb"                = true
  }

  create_cluster_primary_security_group_tags = false

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })
}
