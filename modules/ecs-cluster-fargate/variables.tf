variable "deployment_prefix" {
  type        = string
  description = "Prefix to use for resources created by this module."
}

variable "container_insights" {
  type        = bool
  description = "Enable CloudWatch Container Insights for the cluster."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources created by this module."
  default     = {}
}
