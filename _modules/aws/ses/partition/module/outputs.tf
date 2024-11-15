
output "smtp_server" {
  value = "email-smtp.${var.region}.amazonaws.com"
}
output "smtp_port" {
  value = "587"
}
output "smtp_use_tls" {
  value = true
}


output "arn_raw" {
  value = replace(aws_sesv2_email_identity.main.arn, aws_sesv2_email_identity.main.email_identity, "*")
}

output "aws_sesv2_configuration_set_arn" {
  value = aws_sesv2_configuration_set.main.arn
}
