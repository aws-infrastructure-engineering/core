locals {
  name = "${var.deployment_prefix}-ecs-cluster-fargate"

  tags = merge(
    var.tags, { Name = local.name }
  )
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  cluster_name = local.name

  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = var.kms_key_arn
      logging    = "OVERRIDE"
      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  cluster_settings = {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 7
  kms_key_id        = var.kms_key_arn

  tags = local.tags
}
