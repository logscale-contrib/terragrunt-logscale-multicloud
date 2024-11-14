data "authentik_property_mapping_provider_scim" "user" {
  managed = "goauthentik.io/providers/scim/user"
}

data "authentik_property_mapping_provider_scim" "group" {
  managed = "goauthentik.io/providers/scim/group"
}

resource "random_password" "scim" {
  length  = 32
  special = false
}

resource "authentik_provider_scim" "logscale" {
  name                    = "${local.namespace}-scim"
  url                     = "https://${local.fqdn}/api/ext/scim/v2"
  token                   = random_password.scim.result
  property_mappings       = [data.authentik_property_mapping_provider_scim.user.id]
  property_mappings_group = [data.authentik_property_mapping_provider_scim.group.id]

  filter_group                  = authentik_group.users.id
  exclude_users_service_account = true
}
