module "jenkins_controller_ecs_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "jenkins-controller-ecs-service-sg"
  description = "Security group for Jenkins Controller ECS service"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = var.controller_container_definition.http_port
      to_port                  = var.controller_container_definition.http_port
      protocol                 = "tcp"
      description              = "Allow Jenkins Controller HTTP port from ALB"
      source_security_group_id = var.ecs_shared_alb_sg
    }
  ]

  egress_rules = ["all-all"]
}
