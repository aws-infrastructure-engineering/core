include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules//kms"
}

locals {
  account_name      = include.root.inputs.account_name
  environment       = include.root.inputs.environment
  deployment_prefix = "${local.account_name}-${local.environment}"
}

inputs = {
  deployment_prefix = local.deployment_prefix
  aliases           = ["${local.deployment_prefix}-kms"]

  #TODO: Adjust list of key owners, administrators and users/service users
}
