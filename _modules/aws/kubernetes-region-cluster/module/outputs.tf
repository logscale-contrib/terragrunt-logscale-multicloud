output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_name" {
  value = module.eks.cluster_name
}

output "otel_iam_role_arn" {
  value = module.otel_irsa.iam_role_arn
}

output "otel_iam_role_name" {
  value = module.otel_irsa.iam_role_name
}
output "otel_cloud_platform" {
  value = "eks"
}
