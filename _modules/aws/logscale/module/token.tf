resource "dns_address_validation" "logscale" {
  depends_on = [kubectl_manifest.logscale]
  provider   = dns-validation

  name = local.fqdn
  timeouts {
    create = "10m"
  }

}
resource "dns_address_validation" "ingest" {
  depends_on = [kubectl_manifest.logscale]
  provider   = dns-validation

  name = local.fqdn_ingest
  timeouts {
    create = "10m"
  }
}

resource "time_sleep" "dns" {
  depends_on = [
    dns_address_validation.logscale,
    dns_address_validation.ingest
  ]
  create_duration = "1m"
}

data "kubernetes_secret" "root-token" {
  depends_on = [time_sleep.dns]
  metadata {
    name      = "logscale-admin-token"
    namespace = local.namespace
  }
}
