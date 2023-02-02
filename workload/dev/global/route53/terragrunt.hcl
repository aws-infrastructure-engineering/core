include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.10.2"
}

inputs = {
  zones = {
    "thesamcro.com" = {
      comment = "Purchased from GoDaddy. Expires on 21/04/2023."
      tags = {
        "Name" = "thesamcro.com"
      }
    }
  }
}
