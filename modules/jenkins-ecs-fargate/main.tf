resource "aws_ecs_task_definition" "jenkins_controller" {
  family = "jenkins-controller"

  execution_role_arn = aws_iam_role.contoller_task_execution_role.arn
  task_role_arn      = aws_iam_role.controller_task_role.arn

  cpu                      = var.contoller_resources.cpu
  memory                   = var.contoller_resources.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode(
    [
      {
        name      = var.controller_container_definition.name
        image     = var.controller_container_definition.container_image
        essential = true
        portMappings = [
          {
            containerPort = var.controller_container_definition.http_port
            protocol      = "tcp"
          },
          {
            containerPort = var.controller_container_definition.jnlp_port
            protocol      = "tcp"
          },
        ]
        environment = [
          {
            name  = "JENKINS_JAVA_OPTS"
            value = var.controller_container_definition.java_opts
          },
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.jenkins_controller.name
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "service"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "jenkins_controller" {
  name             = var.controller_container_definition.name
  cluster          = var.ecs_cluster_arn
  task_definition  = aws_ecs_task_definition.jenkins_controller.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  deployment_minimum_healthy_percent = var.controller_deployment_percentages.min
  deployment_maximum_percent         = var.controller_deployment_percentages.max

  network_configuration {
    security_groups  = [module.jenkins_controller_ecs_service_sg.security_group_id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_controller.arn
    container_name   = var.controller_container_definition.name
    container_port   = var.controller_container_definition.http_port
  }
}
