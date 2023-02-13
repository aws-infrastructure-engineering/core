include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/acm/aws//wrappers?version=4.3.2"
}

locals {
  thesamcro_domain_name = "thesamcro.com"
}

dependency "route53_zones" {
  config_path                             = "../../global/route53/zones"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    route53_zone_zone_id = {
      public = "Z3P5QSUBK4POTI"
    }
  }
}

inputs = {
  items = {
    thesamcro_wildcard = {
      domain_name = local.thesamcro_domain_name
      zone_id     = dependency.route53_zones.outputs.route53_zone_zone_id.public

      subject_alternative_names = [
        "*.${local.thesamcro_domain_name}"
      ]

      validation_method   = "DNS"
      wait_for_validation = true

      tags = {
        Name = local.thesamcro_domain_name
      }
    }
  }
}
