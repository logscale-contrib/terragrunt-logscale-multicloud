

# variable "iam_role_path" {

# }
# variable "iam_policy_path" {
#   default = "/"
# }
variable "region" {
  type        = string
  description = "(optional) describe your variable"
}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "logscale_current_storage_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_storage_bucket_arn_blue" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_storage_bucket_arn_green" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_export_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_archive_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "service_account" {
  default = "logscale-sa"
}

variable "logscale_license" {
  type        = string
  description = "(optional) describe your variable"
}

variable "force_destroy" {
  default = true
}

variable "domain_name" {
  type        = string
  description = "(optional) describe your variable"
}


variable "tenant" {

}

variable "saml_url" {
  type        = string
  description = "(optional) describe your variable"
}

variable "saml_signing_certificate" {
  type        = string
  description = "(optional) describe your variable"
}
variable "saml_issuer" {
  type        = string
  description = "(optional) describe your variable"
}

variable "scim_token" {
  type = string
}

variable "LogScaleRoot" {
  type        = string
  description = "(optional) describe your variable"
}

variable "kafka_name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "kafka_namespace" {
  type        = string
  description = "(optional) describe your variable"
}
variable "kafka_prefix_increment" {
  type        = string
  description = "(optional) describe your variable"
}

variable "regional_logs_bucket_arn" {
  type        = string
  description = "(optional) describe your variable"
}
variable "regional_sns_topic_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "smtp_server" {

}
variable "smtp_port" {

}
variable "smtp_use_tls" {

}
variable "smtp_user" {

}
variable "smtp_password" {

}
variable "smtp_sender" {

}
