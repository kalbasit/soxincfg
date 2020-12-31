resource "aws_route53_zone" "yl_ktdev_io" {
  name = "yl.ktdev.io"

  tags = {
    Owner     = "wael"
    Terraform = "true"
  }
}

resource "aws_route53_record" "yl_ktdev_io-ns" {
  zone_id = "Z2Z9GTSQB2A5IX"
  name    = "yl.ktdev.io"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.yl_ktdev_io.name_servers
}

