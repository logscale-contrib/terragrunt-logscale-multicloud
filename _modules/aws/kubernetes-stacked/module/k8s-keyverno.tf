
resource "helm_release" "kyverno" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace = "kyverno"
  create_namespace = true
  

  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.0.5"

  wait = false

  values = [file("./k8s-kyverno-values.yaml")]
}



resource "helm_release" "kyverno-policies" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.kyverno
  ]
  namespace = "kyverno"
  

  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  version    = "3.0.4"

  wait = false

  values = [file("./k8s-kyverno-policies-values.yaml")]
}