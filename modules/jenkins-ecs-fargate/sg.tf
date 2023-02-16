module "jenkins_controller_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${local.controller_name}-sg"
  description = "Security group for Jenkins Controller ECS service"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = var.controller_container_definition.http_port
      to_port                  = var.controller_container_definition.http_port
      protocol                 = "tcp"
      description              = "Allow Jenkins Controller HTTP port from ALB"
      source_security_group_id = var.alb_security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(
    {
      Name = "${local.controller_name}-sg"
    },
    var.tags
  )
}
