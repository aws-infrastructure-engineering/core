module "jenkins_controller_efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.1.1"

  # File system
  name           = "${local.controller_name}-fs"
  creation_token = "${local.controller_name}-fs"
  encrypted      = true
  kms_key_arn    = var.kms_key_arn

  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps

  lifecycle_policy = {
    transition_to_ia                    = var.lifecycle_policy.transition_to_ia
    transition_to_primary_storage_class = var.lifecycle_policy.transition_to_primary_storage_class
  }

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(local.azs, var.private_subnets) : k => { subnet_id = v } }
  security_group_description = "Security group for EFS allowing access from the Jenkins controller"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    jenkins_controller = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description              = "Allow Jenkins Controller to access EFS"
      source_security_group_id = module.jenkins_controller_sg.security_group_id
    }
  }

  # Access point(s)
  access_points = {
    tostring(local.controller_name) = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/jenkins"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }

  tags = merge(
    {
      Name = "${local.controller_name}-fs"
    },
    var.tags
  )
}
