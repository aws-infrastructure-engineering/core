variable "deployment_prefix" {
  type        = string
  description = "Prefix to use for resources created by this module."
}

variable "aliases" {
  type        = list(string)
  description = "List of aliases for the KMS key."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources created by this module."
  default     = {}
}
