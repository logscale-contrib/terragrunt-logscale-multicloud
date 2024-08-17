variable "cluster_name" {

}
variable "namespace" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscaleinstance" {
  type        = string
  default     = "logscale"
  description = "(optional) describe your variable"
}
variable "logscale_fqdn" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_fqdn_ingest" {
  type        = string
  description = "(optional) describe your variable"
}

variable "otel_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "otel_cloud_platform" {
  type        = string
  description = "(optional) describe your variable"
}
