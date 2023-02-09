locals {
  name = "${var.deployment_prefix}-kms-key"

  tags = merge(
    var.tags, { Name = local.name }
  )
}


module "kms" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "1.5.0"
  aliases     = var.aliases
  description = "Shared KMS key for ${var.deployment_prefix}."

  # key used for encrypting cloudwatch log groups
  source_policy_documents = [data.aws_iam_policy_document.logs_policy.json]

  tags = local.tags
}
