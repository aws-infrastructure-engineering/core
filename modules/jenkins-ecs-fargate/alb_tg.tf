resource "aws_lb_target_group" "jenkins_controller" {
  name        = "alb-http-jenkins-controller"
  port        = var.controller_container_definition.http_port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/login"
    timeout             = 10
    interval            = 45
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "jenkins_controller" {
  listener_arn = var.lb_listener_https_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_controller.arn
  }

  condition {
    host_header {
      values = ["jenkins.${var.route53_zone_name}"]
    }
  }
}
