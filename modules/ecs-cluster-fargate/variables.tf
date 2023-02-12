variable "deployment_prefix" {
  type        = string
  description = "Prefix to use for resources created by this module"
}

variable "capacity_provider_wight" {
  type = object({
    fargate      = number
    fargate_spot = number
  })
  description = "Weight of Fargate and Fargate Spot capacity providers"
  default = {
    fargate      = 10
    fargate_spot = 90
  }
}

variable "container_insights" {
  type        = bool
  description = "Enable CloudWatch Container Insights for the cluster"
  default     = false
}

variable "ecs_log_retention_days" {
  type        = number
  description = "Number of days to retain ECS logs"
  default     = 14
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN to use for encrypting resources"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources created by this module"
  default     = {}
}
