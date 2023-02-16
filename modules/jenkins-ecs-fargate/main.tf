locals {
  controller_name = "${var.deployment_prefix}-jenkins-controller"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_ecs_task_definition" "jenkins_controller" {
  family = local.controller_name

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
        mountPoints = [
          {
            sourceVolume  = "${local.controller_name}-efs"
            containerPath = "/var/jenkins_home"
          },
        ]
        portMappings = [
          {
            containerPort = var.controller_container_definition.http_port
          },
          {
            containerPort = var.controller_container_definition.jnlp_port
          },
        ]
        # environment = [
        #   {
        #     name  = "JAVA_OPTS"
        #     value = var.controller_container_definition.java_opts
        #   },
        # ]
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

  volume {
    name = "${local.controller_name}-efs"

    efs_volume_configuration {
      file_system_id     = module.jenkins_controller_efs.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = module.jenkins_controller_efs.access_points[local.controller_name].id
        iam             = "ENABLED"
      }
    }
  }

  tags = merge(
    {
      Name = local.controller_name
    },
    var.tags
  )
}

resource "aws_ecs_service" "jenkins_controller" {
  name             = "${local.controller_name}-service"
  cluster          = var.ecs_cluster_arn
  task_definition  = aws_ecs_task_definition.jenkins_controller.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  deployment_minimum_healthy_percent = var.controller_deployment_percentages.min
  deployment_maximum_percent         = var.controller_deployment_percentages.max

  service_registries {
    registry_arn = aws_service_discovery_service.jenkins_controller.arn
    port         = var.controller_container_definition.jnlp_port
  }

  network_configuration {
    security_groups  = [module.jenkins_controller_sg.security_group_id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_controller.arn
    container_name   = var.controller_container_definition.name
    container_port   = var.controller_container_definition.http_port
  }

  tags = merge(
    {
      Name = "${local.controller_name}-service"
    },
    var.tags
  )
}

resource "aws_service_discovery_private_dns_namespace" "jenkins_controller" {
  name        = local.controller_name
  vpc         = var.vpc_id
  description = "Serverless Jenkins discovery managed zone"
}

resource "aws_service_discovery_service" "jenkins_controller" {
  name = local.controller_name

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.jenkins_controller.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}
