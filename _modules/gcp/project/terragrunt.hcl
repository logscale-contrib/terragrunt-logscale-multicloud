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
  source = "git::https://github.com/terraform-google-modules/terraform-google-project-factory.git?ref=v17.1.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))

}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  project_id = local.provider.google.project_id
  // activate_apis = [
  //   "artifactregistry.googleapis.com",
  //   "autoscaling.googleapis.com",
  //   "bigquery.googleapis.com",
  //   "bigquerymigration.googleapis.com",
  //   "bigquerystorage.googleapis.com",
  //   "certificatemanager.googleapis.com",
  //   "cloudapis.googleapis.com",
  //   "cloudresourcemanager.googleapis.com",
  //   "compute.googleapis.com",
  //   "container.googleapis.com",
  //   "containeranalysis.googleapis.com",
  //   "containerfilesystem.googleapis.com",
  //   "containerregistry.googleapis.com",
  //   "containerscanning.googleapis.com",
  //   "dataflow.googleapis.com",
  //   "datastore.googleapis.com",
  //   "deploymentmanager.googleapis.com",
  //   "dns.googleapis.com",
  //   "file.googleapis.com",
  //   "iam.googleapis.com",
  //   "iamcredentials.googleapis.com",
  //   "logging.googleapis.com",
  //   "monitoring.googleapis.com",
  //   "oslogin.googleapis.com",
  //   "pubsub.googleapis.com",
  //   "secretmanager.googleapis.com",
  //   "servicemanagement.googleapis.com",
  //   "serviceusage.googleapis.com",
  //   "sql-component.googleapis.com",
  //   "storage-api.googleapis.com",
  //   "storage-component.googleapis.com",
  //   "storage.googleapis.com",
  //   "storageinsights.googleapis.com",
  //   "containersecurity.googleapis.com"
  // ]
}
