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
  source = "git::https://github.com/terraform-google-modules/terraform-google-network.git?ref=v10.0.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {


  gcp_vars   = read_terragrunt_config(find_in_parent_folders("gcp.hcl"))
  project_id = local.gcp_vars.locals.project_id
  region     = local.gcp_vars.locals.region

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  codename  = local.environment_vars.locals.codename
  env       = local.environment_vars.locals.environment
  geo       = local.environment_vars.locals.geo
  name_vars = read_terragrunt_config(find_in_parent_folders("name.hcl"))
  name      = local.name_vars.locals.name

}

dependencies {
  paths = [
    "${get_terragrunt_dir()}/../../../project/"
  ]
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  network_name = join("-", compact([local.codename, local.env, local.geo, local.name]))
  routing_mode = "GLOBAL"
  project_id   = local.project_id

  mtu = 8896
  subnets = [
    {
      subnet_name   = "${join("-", compact([local.codename, local.env, local.geo, local.name]))}-k8s"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = local.region
    },
    # {
    #   subnet_name   = "k8s-svc"
    #   subnet_ip     = "10.0.2.0/23"
    #   subnet_region = "us-central1"
    # },
    # {
    #   subnet_name           = "k8s-pods"
    #   subnet_ip             = "10.0.4.0/23"
    #   subnet_region         = "us-central1"
    #   subnet_private_access = "true"
    #   # subnet_flow_logs      = "true"
    # }

  ]
  secondary_ranges = {
    "${join("-", compact([local.codename, local.env, local.geo, local.name]))}-k8s" = [
      {
        range_name    = "${join("-", compact([local.codename, local.env, local.geo, local.name]))}-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${join("-", compact([local.codename, local.env, local.geo, local.name]))}-svc"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

}
