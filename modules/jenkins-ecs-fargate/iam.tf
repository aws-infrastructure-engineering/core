resource "aws_iam_role" "contoller_task_execution_role" {
  name               = "${local.controller_name}-ecs-task-execution-role"
  description        = "Role used by ECS to push Jenkins Controller logs to Cloudwatch and access ECR"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json

  tags = merge(
    {
      Name = "${local.controller_name}-task-execution-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "contoller_task_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.contoller_task_execution_role.name
}

resource "aws_iam_role" "controller_task_role" {
  name                  = "${local.controller_name}-ecs-task"
  description           = "Role used by the Jenkins Controller to access AWS resources"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role_policy.json
  force_detach_policies = true

  tags = merge(
    {
      Name = "${local.controller_name}-task-role"
    },
    var.tags
  )
}

resource "aws_iam_policy" "controller_task_role_policy" {
  name        = "${local.controller_name}-ecs-task-role-policy"
  description = "Policy for Jenkins Controller task role"
  policy      = data.aws_iam_policy_document.controller_task_role_policy.json

  tags = merge(
    {
      Name = "${local.controller_name}-task-role-policy"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "controller_task_role_policy_attachment" {
  role       = aws_iam_role.controller_task_role.name
  policy_arn = aws_iam_policy.controller_task_role_policy.arn
}
