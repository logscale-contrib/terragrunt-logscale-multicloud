resource "helm_release" "logscale-operator" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.cert-manager
  ]

  namespace        = "logscale-operator"
  create_namespace = true

  name       = "logscale-operator"
  repository = "https://humio.github.io/humio-operator"
  chart      = "humio-operator"
  version    = "0.20.1"

  values = [templatefile("./k8s-logscale-operator.yaml", {})]
}
