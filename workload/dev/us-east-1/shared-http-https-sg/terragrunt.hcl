include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws//.?version=4.17.1"
}

locals {
  account_name = include.root.inputs.account_name
  environment  = include.root.inputs.environment
  name         = "${local.account_name}-${local.environment}-${basename(get_terragrunt_dir())}"
}

dependency "vpc_mgmt" {
  config_path                             = "../networking/vpc-mgmt"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

inputs = {
  name                = local.name
  description         = "Shared security group with HTTP and HTTPS ingress rules"
  vpc_id              = dependency.vpc_mgmt.outputs.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}
