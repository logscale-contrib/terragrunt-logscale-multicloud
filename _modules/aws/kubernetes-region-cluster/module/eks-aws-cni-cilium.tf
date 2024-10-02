# data "kubernetes_endpoints_v1" "api_endpoints" {
#   metadata {
#     name      = "kubernetes"
#     namespace = "default"
#   }
# }

locals {
  k8shost = regex("https://(.*)", module.eks.cluster_endpoint)[0]
  #k8shost=flatten(data.kubernetes_endpoints_v1.api_endpoints.subset[*].address[*].ip)[0]
}
resource "helm_release" "cilium" {
  depends_on = [
    module.eks.eks_managed_node_groups,
    module.eks.access_entries,
    module.eks.access_policy_associations,
    module.eks.cloudwatch_log_group_arn
  ]
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  name       = "cilium"
  namespace  = "kube-system"
  version    = var.component_versions["cilium"]
  values = [<<YAML
cni:
  chainingMode: aws-cni
  exclusive: false
routingMode: native
enableIPv4Masquerade: false
enableIPv6Masquerade: false
rollOutCiliumPods: true
endpointRoutes:
  enabled: true
ipv6:
  enabled: true
kubeProxyReplacement: true
loadBalancer:
  # acceleration: native
  mode: dsr
k8sServicePort: 443
k8sServiceHost: ${local.k8shost}
operator:
  podDisruptionBudget:
    enabled: true
  extraArgs:
    - --pod-restart-selector=ciliumDoNotRestart != true
hubble:
  relay:
    enabled: true
  ui:
    enabled: true
nodeinit:
  enabled: false
  startup:
    preScript: |
      #
        ip link set dev eth0 mtu 3498
        ip link show eth0
        ethtool -l eth0
        x=$(( $(ethtool -l eth0 | grep Combined | head -1 | sed 's|Combined:\s*||g') /2))
        echo ethtool -L eth0 combined $x
        ethtool -L eth0 combined 2 || true
      #
YAML
  ]
}

resource "random_string" "ca" {
  length  = 8
  special = false
}

resource "null_resource" "kubeproxy" {
  depends_on = [helm_release.cilium]
  triggers = {
    // fire any time the cluster is update in a way that changes its endpoint or auth
    endpoint        = module.eks.cluster_endpoint
    cluster_version = module.eks.cluster_version
    cilium          = helm_release.cilium.metadata[0].revision
  }
  provisioner "local-exec" {
    command = <<EOH
cat >/tmp/${random_string.ca.result}.crt <<EOF
${base64decode(module.eks.cluster_certificate_authority_data)}
EOF
token=$(aws eks get-token --cluster-name ${module.eks.cluster_name} | jq -r '.status.token')
kubectl \
  --server="${module.eks.cluster_endpoint}" \
  --certificate_authority=/tmp/${random_string.ca.result}.crt \
  --token="$token" \
  -n kube-system delete ds kube-proxy
kubectl \
  --server="${module.eks.cluster_endpoint}" \
  --certificate_authority=/tmp/${random_string.ca.result}.crt \
  --token="$token" \
  -n kube-system delete cmkubectl-c kube-proxy
rm /tmp/${random_string.ca.result}.crt
EOH
  }
}
