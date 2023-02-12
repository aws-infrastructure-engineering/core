include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/route53/aws//modules/zones?version=2.10.2"
}

locals {
  domain_name = "thesamcro.com"
}

inputs = {
  zones = {
    public = {
      domain_name = local.domain_name
      comment     = "Purchased from GoDaddy. Expires on 21/04/2023"
      tags = {
        Name = local.domain_name
      }
    }
  }
}
