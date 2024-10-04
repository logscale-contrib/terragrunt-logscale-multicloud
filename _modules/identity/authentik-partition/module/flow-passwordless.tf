resource "authentik_flow" "lrp" {
  name        = "lr-passwordless"
  title       = "Password Less Authentication"
  slug        = "lr-passwordless"
  designation = "authentication"
}


data "authentik_stage" "setup-webauthn" {
  name = "default-authenticator-webauthn-setup"
}

resource "authentik_stage_authenticator_validate" "lrp-authenticator-webauthn-validate" {
  name                       = "lrp-authenticator-validate"
  device_classes             = ["webauthn"]
  not_configured_action      = "configure"
  webauthn_user_verification = "required"
  configuration_stages = [
    data.authentik_stage.setup-webauthn.id
  ]
}

resource "authentik_flow_stage_binding" "lrp-auth-webauthn" {
  target = authentik_flow.lrp.uuid
  stage  = authentik_stage_authenticator_validate.lrp-authenticator-webauthn-validate.id
  order  = 10
}

resource "authentik_flow_stage_binding" "lrp-auth-login" {
  target = authentik_flow.lrp.uuid
  stage  = data.authentik_stage.default-authentication-login.id
  order  = authentik_flow_stage_binding.lrp-auth-webauthn.order + 10

  evaluate_on_plan     = false
  re_evaluate_policies = true
}
