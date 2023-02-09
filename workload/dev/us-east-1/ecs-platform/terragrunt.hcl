include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules//ecs-cluster-fargate"
}

dependency "kms_key" {
  config_path                             = "../kms"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

locals {
  account_name      = include.root.inputs.account_name
  environment       = include.root.inputs.environment
  deployment_prefix = "${local.account_name}-${local.environment}"
  kms_key_id        = dependency.kms_key.outputs.kms_key_id
}

inputs = {
  deployment_prefix = local.deployment_prefix
}
