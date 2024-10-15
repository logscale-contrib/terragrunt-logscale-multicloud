data "authentik_property_mapping_provider_scim" "user" {
  managed = "goauthentik.io/providers/scim/user"
}

data "authentik_property_mapping_provider_scim" "group" {
  managed = "goauthentik.io/providers/scim/group"
}

resource "authentik_provider_scim" "logscale" {
  name                    = "${local.namespace}-scim"
  url                     = "https://f7ca-2603-9001-7000-33a6-e56c-d62f-f1a4-f8ef.ngrok-free.app"
  token                   = "004f2af45d3a4e161a7dd2d17fdae47f"
  property_mappings       = [data.authentik_property_mapping_provider_scim.user.id]
  property_mappings_group = [data.authentik_property_mapping_provider_scim.group.id]

  filter_group                  = authentik_group.users.id
  exclude_users_service_account = true
}
