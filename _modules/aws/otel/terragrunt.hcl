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
  //source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.21.0"
  source = "${dirname(find_in_parent_folders())}/_modules/aws/otel/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider  = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))
  platform  = yamldecode(file(find_in_parent_folders("platform.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))

}
dependency "kubernetes_base" {
  config_path = "${get_terragrunt_dir()}/../kubernetes-region-cluster/"
  mock_outputs = {
    cluster_name = "foo"
  }
}
dependency "logscale" {
  config_path = "${get_terragrunt_dir()}/../../../../partition/logscale/logscale/"
}



# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name         = dependency.kubernetes_base.outputs.cluster_name
  namespace            = dependency.logscale.outputs.namespace
  logscale_fqdn        = dependency.logscale.outputs.logscale_fqdn
  logscale_fqdn_ingest = dependency.logscale.outputs.logscale_fqdn_ingest

  otel_arn = dependency.kubernetes_base.outputs.otel_iam_role_arn
  otel_cloud_platform = dependency.kubernetes_base.outputs.otel_cloud_platform
}
