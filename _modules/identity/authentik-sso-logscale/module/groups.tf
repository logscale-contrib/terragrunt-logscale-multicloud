
data "authentik_user" "management-cluster" {
  for_each = toset(var.management-cluster)
  username = each.key
}

data "authentik_user" "management-organization" {
  for_each = toset(var.management-organization)
  username = each.key
}

data "authentik_user" "users" {
  for_each = toset(var.users)
  username = each.key
}


resource "authentik_group" "management-cluster" {
  name       = "${var.tenant}-${var.app_name}-management-cluster"
  attributes = "{\"tenant\": \"${var.tenant}\", \"app\": \"${var.app_name}\", \"LogScaleIsRoot\": true}"
  users      = [for u in data.authentik_user.management-cluster : u.id]
}
resource "authentik_group" "management-organization" {
  name       = "${var.tenant}-${var.app_name}-management-organization"
  attributes = "{\"tenant\": \"${var.tenant}\", \"app\": \"${var.app_name}\", \"LogScaleIsRoot\": true}"
  users      = [for u in data.authentik_user.management-organization : u.id]
}

resource "authentik_group" "users" {
  name       = "${var.tenant}-${var.app_name}-users"
  attributes = "{\"tenant\": \"${var.tenant}\", \"app\": \"${var.app_name}\"}"
  users      = [for u in data.authentik_user.users : u.id]
}
