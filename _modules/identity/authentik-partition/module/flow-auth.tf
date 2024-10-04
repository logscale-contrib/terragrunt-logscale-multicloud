resource "authentik_flow" "lr" {
  name        = "lr-authentication"
  title       = "Authentication"
  slug        = "lr-authentication"
  designation = "authentication"
}

data "authentik_stage" "default-authentication-password" {
  name = "default-authentication-password"
}

resource "authentik_stage_identification" "lr-authentication-identification" {
  name = "lr-authentication-identification"

  user_fields               = ["username", "email"]
  case_insensitive_matching = true

  password_stage    = data.authentik_stage.default-authentication-password.id
  passwordless_flow = authentik_flow.lrp.uuid
  recovery_flow     = data.authentik_flow.flow_recovery.id

}
resource "authentik_flow_stage_binding" "auth-identification" {
  target = authentik_flow.lr.uuid
  stage  = authentik_stage_identification.lr-authentication-identification.id
  order  = 10
}


data "authentik_stage" "setup-totp" {
  name = "default-authenticator-totp-setup"
}


resource "authentik_stage_authenticator_validate" "lr-authenticator-validate" {
  name                       = "lr-authenticator-validate"
  device_classes             = ["totp", "webauthn"]
  not_configured_action      = "configure"
  webauthn_user_verification = "required"
  configuration_stages = [
    data.authentik_stage.setup-totp.id,
    data.authentik_stage.setup-webauthn.id
  ]
}

resource "authentik_flow_stage_binding" "auth-mfa" {
  target = authentik_flow.lr.uuid
  stage  = authentik_stage_authenticator_validate.lr-authenticator-validate.id
  order  = authentik_flow_stage_binding.auth-identification.order + 10
}


data "authentik_stage" "default-authentication-login" {
  name = "default-authentication-login"
}
resource "authentik_flow_stage_binding" "auth-login" {
  target = authentik_flow.lr.uuid
  stage  = data.authentik_stage.default-authentication-login.id


  evaluate_on_plan     = false
  re_evaluate_policies = true

  order = authentik_flow_stage_binding.auth-mfa.order + 10

}
