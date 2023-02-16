include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules//jenkins-ecs-fargate"
}

locals {
  account_name      = include.root.inputs.account_name
  environment       = include.root.inputs.environment
  deployment_prefix = "${local.account_name}-${local.environment}"
}

dependency "ecs_cluster_fargate" {
  config_path                             = "../ecs-cluster-fargate"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    cluster_arn  = "arn:aws:ecs:us-east-1:123456789012:cluster/ecs-cluster"
    cluster_name = "fake-ecs-cluster"
  }
}

dependency "vpc_mgmt" {
  config_path                             = "../networking/vpc-mgmt"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    vpc_id = "vpc-12345678"
    private_subnets = [
      "subnet-12345678",
      "subnet-12345678",
      "subnet-12345678",
    ]
  }
}

dependency "shared_http_https_sg" {
  config_path                             = "../shared-http-https-sg"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    security_group_id = "sg-12345678"
  }
}

dependency "ecs_shared_alb" {
  config_path                             = "../ecs-shared-alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    lb_dns_name = "fake-dns-name"
    lb_zone_id  = "fake-zone-id"
    https_listener_arns = [
      "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/lb-name/1234567890123456/1234567890123456",
    ]
  }
}

dependency "route53_zones" {
  config_path                             = "../../global/route53/zones"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    route53_zone_name = {
      public = "example.com"
    }
  }
}

dependency "shared_kms_key" {
  config_path                             = "../shared-kms-key"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

inputs = {
  deployment_prefix = local.deployment_prefix
  ecs_cluster_arn   = dependency.ecs_cluster_fargate.outputs.cluster_arn
  ecs_cluster_name  = dependency.ecs_cluster_fargate.outputs.cluster_name
  controller_container_definition = {
    name            = "jenkins-controller"
    container_image = "jenkins/jenkins:lts-jdk11"
    http_port       = 8080
    jnlp_port       = 50000
    java_opts       = "--Djenkins.install.runSetupWizard=false"
  }

  vpc_id                = dependency.vpc_mgmt.outputs.vpc_id
  private_subnets       = dependency.vpc_mgmt.outputs.private_subnets
  alb_security_group_id = dependency.shared_http_https_sg.outputs.security_group_id

  alb_dns_name           = dependency.ecs_shared_alb.outputs.lb_dns_name
  alb_zone_id            = dependency.ecs_shared_alb.outputs.lb_zone_id
  alb_https_listener_arn = dependency.ecs_shared_alb.outputs.https_listener_arns[0]
  route53_zone_name      = dependency.route53_zones.outputs.route53_zone_name.public

  kms_key_arn = dependency.shared_kms_key.outputs.key_arn
}
