variable "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster to run the Jenkins controller task"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster to run the Jenkins controller task"
  type        = string
}

variable "controller_container_definition" {
  description = "Container definition for the Jenkins controller"
  type = object({
    name            = string
    container_image = string
    http_port       = number
    jnlp_port       = number
    java_opts       = string
  })
}

variable "contoller_resources" {
  description = "CPU and memory resources for the Jenkins controller"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1024
    memory = 2048
  }
}

variable "fargate_platform_version" {
  description = "Fargate platform version to use"
  type        = string
  default     = "LATEST"
}

variable "controller_deployment_percentages" {
  description = "Minimum and maximum deployment percentages for the Jenkins controller"
  type = object({
    min = number
    max = number
  })
  default = {
    min = 0
    max = 100
  }
}

variable "vpc_id" {
  description = "VPC ID to use for resources"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets to place workloads"
  type        = list(string)
}

variable "ecs_shared_alb_sg" {
  description = "Security group ID of the ALB shared for the ECS cluster"
  type        = string
}

variable "lb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  type        = string
}

variable "lb_listener_https_arn" {
  description = "ARN of the HTTPS listener on the ALB"
  type        = string
}

variable "route53_zone_name" {
  description = "Root domain name for the Jenkins controller"
  type        = string
}

variable "controller_log_retention_days" {
  description = "Number of days to retain Jenkins controller logs"
  type        = number
  default     = 14
}

variable "kms_key_arn" {
  description = "KMS key ARN to use for encrypting resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources created by this module"
  type        = map(string)
  default     = {}
}
