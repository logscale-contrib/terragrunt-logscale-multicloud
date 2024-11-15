# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.

terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/aws/ses/mailuser/module/"
}



# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  global    = yamldecode(file(find_in_parent_folders("global.yaml")))
}

dependency "smtp" {
  config_path = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/ses/"
}

inputs = {

  email_user_name_prefix = "${local.partition.name}"
  arn_raw = dependency.smtp.outputs.arn_raw
  aws_sesv2_configuration_set_arn = dependency.smtp.outputs.aws_sesv2_configuration_set_arn
}
