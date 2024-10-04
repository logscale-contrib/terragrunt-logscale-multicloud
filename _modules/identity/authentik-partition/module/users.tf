resource "authentik_user" "name" {
  for_each = var.users
  name     = each.value.name
  email    = each.value.email

  username = each.key
  # groups   = [authentik_group.group.id]
}
