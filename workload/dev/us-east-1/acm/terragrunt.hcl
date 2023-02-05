include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-acm.git//wrappers?ref=v4.3.2"
}

locals {
  domain_name = "thesamcro.com"
}

dependency "route53_zones" {
  config_path                             = "../../global/route53/zones"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    zone_id = {
      tostring(local.domain_name) = "fake-zone-id"
    }
  }
}

inputs = {
  items = {
    tostring(local.domain_name) = {
      domain_name = local.domain_name
      zone_id     = dependency.route53_zones.outputs.zone_id[local.domain_name]

      subject_alternative_names = [
        "*.${local.domain_name}"
      ]

      validation_method   = "DNS"
      wait_for_validation = true

      tags = {
        "Name" = local.domain_name
      }
    }
  }
}
