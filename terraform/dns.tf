data "aws_route53_zone" "primary" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.primary.id
  name    = var.route53_zone_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.route53_zone_name
  validation_method = "DNS"
}

