module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.0"

  domain_name = "*.${var.tenant}.${var.cert_domain}"
  zone_id     = var.parent_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.tenant}.${var.cert_domain}",
    "${var.tenant}.${var.cert_domain}",
  ]

  wait_for_validation = true

  key_algorithm = "EC_secp384r1"

}
