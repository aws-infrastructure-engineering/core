include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules//ecs-cluster-fargate"
}

dependency "shared_kms_key" {
  config_path                             = "../shared-kms-key"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

locals {
  account_name = include.root.inputs.account_name
  environment  = include.root.inputs.environment
  cluster_name = "${local.account_name}-${local.environment}-${basename(get_terragrunt_dir())}"
}

inputs = {
  cluster_name = local.cluster_name
  kms_key_arn  = dependency.shared_kms_key.outputs.key_arn
}
