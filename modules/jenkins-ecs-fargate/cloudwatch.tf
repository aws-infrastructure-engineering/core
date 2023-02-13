resource "aws_cloudwatch_log_group" "jenkins_controller" {
  name              = "/aws/ecs/${var.ecs_cluster_name}/jenkins/controller"
  retention_in_days = var.controller_log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(
    {
      Name = "${local.controller_name}-log-group"
    },
    var.tags
  )
}
