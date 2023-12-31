# #https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/

# module "eks_blueprints_addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "1.12.0"

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   eks_addons = {

#     aws-ebs-csi-driver = {
#       most_recent                 = true
#       resolve_conflicts_on_create = "OVERWRITE"
#       resolve_conflicts_on_update = "OVERWRITE"
#       configuration_values = jsonencode({
#         controller = {
#           resources = {
#             limits = {
#               cpu    = ".25"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = ".25"
#               memory = "512Mi"
#             }
#           }
#           "affinity" : {
#             "nodeAffinity" : {
#               "requiredDuringSchedulingIgnoredDuringExecution" : {
#                 "nodeSelectorTerms" : [
#                   {
#                     "matchExpressions" : [
#                       {
#                         "key" : "kubernetes.io/os",
#                         "operator" : "In",
#                         "values" : [
#                           "linux"
#                         ]
#                       }
#                     ]
#                   }
#                 ]
#               }
#             },
#             "podAntiAffinity" : {
#               "preferredDuringSchedulingIgnoredDuringExecution" : [
#                 {
#                   "podAffinityTerm" : {
#                     "labelSelector" : {
#                       "matchExpressions" : [
#                         {
#                           "key" : "app.kubernetes.io/component",
#                           "operator" : "In",
#                           "values" : [
#                             "csi-driver"
#                           ]
#                         }
#                       ]
#                     },
#                     "topologyKey" : "kubernetes.io/hostname"
#                   },
#                   "weight" : 100
#                 }
#               ]
#             }
#           }

#         }
#         }
#       )
#     }
#     eks-pod-identity-agent = {
#       most_recent                 = true
#       resolve_conflicts_on_create = "OVERWRITE"
#       resolve_conflicts_on_update = "OVERWRITE"
#     }
#   }

#   enable_aws_load_balancer_controller = true
#   aws_load_balancer_controller = {
#     set = [
#       {
#         name  = "vpcId"
#         value = var.vpc_id
#       },
#       {
#         name  = "region"
#         value = var.cluster_region
#       },
#       {
#         name  = "podDisruptionBudget.maxUnavailable"
#         value = "1"
#       },
#       {
#         name  = "resources.requests.cpu"
#         value = "100m"
#       },
#       {
#         name  = "resources.requests.memory"
#         value = "128Mi"
#       },
#       {
#         name  = "resources.limits.cpu"
#         value = "1"
#       },
#       {
#         name  = "resources.limits.memory"
#         value = "256Mi"
#       },
#     ]
#   }

#   enable_aws_efs_csi_driver = true

#   enable_metrics_server = true
#   # metrics_server = {
#   #   set = [
#   #     {
#   #       name = "args"
#   #       value = [
#   #         "--kubelet-insecure-tls",
#   #         "--kubelet-preferred-address-types=InternalIP",
#   #       ]
#   #     },
#   #   ]
#   # }
#   enable_vpa = true

#   enable_external_dns            = true
#   external_dns_route53_zone_arns = var.external_dns_route53_zone_arns

#   enable_cert_manager = true

#   helm_releases = {
#     karpentercrds = {
#       description      = "A Helm chart for k8s karpenter"
#       namespace        = "karpenter"
#       create_namespace = true
#       chart            = "karpenter-crd"
#       chart_version    = "v0.33.0"
#       repository       = "oci://public.ecr.aws/karpenter"
#     }
#     karpenter = {
#       description      = "A Helm chart for k8s karpenter"
#       namespace        = "karpenter"
#       create_namespace = true
#       chart            = "karpenter"
#       chart_version    = "v0.33.0"
#       repository       = "oci://public.ecr.aws/karpenter"
#       skip_crds        = true
#       values = [<<-YAML
#         settings:
#           clusterName: "${module.eks.cluster_name}"
#           clusterEndpoint: ${module.eks.cluster_endpoint}
#           interruptionQueueName: ${module.karpenter.queue_name}
#         serviceAccount:
#           annotations:
#             eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}           
#         controller:
#           resources:
#             requests:
#               cpu: 1
#               memory: 256Mi
#             limits:
#               cpu: 1
#               memory: 256Mi                
#         YAML
#       ]
#     }
#   }
# }

# resource "time_sleep" "addons" {
#   depends_on       = [module.eks_blueprints_addons]
#   destroy_duration = "300s"
# }
# resource "kubernetes_annotations" "coredns" {
#   depends_on = [module.eks_blueprints_addons]

#   api_version = "apps/v1"
#   kind        = "Deployment"
#   metadata {
#     name      = "coredns"
#     namespace = "kube-system"
#   }
#   # These annotations will be applied to the Pods created by the Deployment
#   template_annotations = {
#     "eks.amazonaws.com/compute-type" = "fargate"
#   }
# }
