
data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
  vars = {
    namespace         = var.namespace
    cluster_name      = var.cluster_name
    allowDataDeletion = true
  }
}

resource "kubectl_manifest" "flux2-releases" {

  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
