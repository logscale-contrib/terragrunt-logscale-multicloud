resource "authentik_policy_binding" "app-access" {
  target = authentik_application.name.uuid
  group  = authentik_group.users.id
  order  = 0
}
