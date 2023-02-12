include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/alb/aws//.?version=8.3.1"
}

locals {
  account_name = include.root.inputs.account_name
  environment  = include.root.inputs.environment
  name         = "${local.account_name}-${local.environment}-ecs-shared-alb"
}

dependency "acm" {
  config_path                             = "../acm"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    wrapper = {
      public = {
        acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      }
    }
  }
}

dependency "vpc" {
  config_path                             = "../networking/vpc-mgmt"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    vpc_id = "vpc-12345678"
    public_subnets = [
      "subnet-12345678",
      "subnet-12345678",
      "subnet-12345678",
    ]
  }
}

dependency "ecs_shared_alb_sg" {
  config_path                             = "../ecs-shared-alb-sg"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    security_group_id = "sg-12345678"
  }
}

inputs = {
  name = local.name

  load_balancer_type = "application"

  vpc_id                = dependency.vpc.outputs.vpc_id
  subnets               = dependency.vpc.outputs.public_subnets
  create_security_group = false
  security_groups       = [dependency.ecs_shared_alb_sg.outputs.security_group_id]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.wrapper.thesamcro_wildcard.acm_certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "404: Not Found"
        status_code  = "404"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Name = local.name
  }
}
