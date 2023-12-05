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
  source = "tfr:///Azure/network/azurerm?version=5.3.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
 provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
 region = yamldecode(file(find_in_parent_folders("region.yaml")))
 
}

dependency "resourceGroup" {
  config_path = "${get_terragrunt_dir()}/../../resourcegroup/"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  vnet_name = "${dependency.resourceGroup.outputs.resource_group_name}-${local.region.outputs.region}"
  resource_group = dependency.resourceGroup.outputs.resource_group_name
  location   = local.region.outputs.region
  tags = local.provider.azure.tags

  use_for_each = true

  address_spaces = locals.region.network.address_spaces
}