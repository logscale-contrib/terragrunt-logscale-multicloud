
variable "domain_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "tenant" {

}

variable "url" {
  type        = string
  description = "(optional) describe your variable"
}
variable "token" {
  type        = string
  description = "(optional) describe your variable"
}
variable "app_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "management-cluster" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "management-organization" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "users" {
  type        = list(string)
  description = "(optional) describe your variable"
}
