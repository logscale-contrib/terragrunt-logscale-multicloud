
data "authentik_user" "rootusers" {
  for_each = toset(var.rootUsers)
  username = each.key
}

resource "authentik_group" "root" {
  name       = "${var.tenant}-${var.app_name}-root"
  attributes = "{\"tenant\": \"${var.tenant}\", \"app\": \"${var.app_name}\", \"LogScaleIsRoot\": true}"
  users      = [for u in data.authentik_user.rootusers : u.id]
}

resource "authentik_group" "users" {
  name       = "${var.tenant}-${var.app_name}-users"
  attributes = "{\"tenant\": \"${var.tenant}\", \"app\": \"${var.app_name}\"}"
}
