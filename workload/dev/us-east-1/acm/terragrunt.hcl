include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/acm/aws//wrappers?version=4.3.2"
}

locals {
  domain_name = "thesamcro.com"
}

dependency "route53_zones" {
  config_path                             = "../../global/route53/zones"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    route53_zone_zone_id = {
      tostring(local.domain_name) = "fake-zone-id"
    }
  }
}

inputs = {
  items = {
    tostring(local.domain_name) = {
      domain_name = local.domain_name
      zone_id     = dependency.route53_zones.outputs.route53_zone_zone_id[local.domain_name]

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
