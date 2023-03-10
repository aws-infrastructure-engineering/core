include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/ecr/aws//wrappers?version=1.5.1"
}

dependency "shared_kms_key" {
  config_path                             = "../shared-kms-key"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "terragrunt-info", "show"]
  mock_outputs = {
    key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

locals {
  jenkins_controller_repository_name = "jenkins-controller-ecs"
}

inputs = {
  items = {
    jenkins_controller_ecs = {
      repository_name                 = local.jenkins_controller_repository_name
      repository_image_tag_mutability = "MUTABLE"

      repository_encryption_type = "KMS"
      repository_kms_key         = dependency.shared_kms_key.outputs.key_arn

      #TODO: Update Reader and Writer ARNs or provide custom policy

      repository_lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep only the 3 most recent images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 3
            }
            action = {
              type = "expire"
            }
          }
        ]
      })

      tags = {
        Name = local.jenkins_controller_repository_name
      }
    }
  }
}
