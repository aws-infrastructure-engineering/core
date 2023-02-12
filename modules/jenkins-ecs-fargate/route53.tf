module "route53_record" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.2"

  zone_name = var.route53_zone_name

  records = [
    {
      name = "jenkins"
      type = "A"

      alias = {
        name                   = var.lb_dns_name
        zone_id                = var.lb_zone_id
        evaluate_target_health = false
      }
    }
  ]
}
