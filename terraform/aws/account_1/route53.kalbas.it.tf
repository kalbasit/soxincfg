resource "aws_route53_zone" "kalbas-it" {
  name = "kalbas.it"
}

resource "aws_route53_record" "kalbas-it-ns" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "kalbas.it"
  type    = "NS"
  ttl     = "172800"

  records = [
    aws_route53_zone.kalbas-it.name_servers[0],
    aws_route53_zone.kalbas-it.name_servers[1],
    aws_route53_zone.kalbas-it.name_servers[2],
    aws_route53_zone.kalbas-it.name_servers[3],
  ]
}

resource "aws_route53_record" "kalbas-it-mx" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "kalbas.it"
  type    = "MX"
  ttl     = 86400

  records = [
    "10 mail.protonmail.ch",
    "20 mailsec.protonmail.ch",
  ]
}

resource "aws_route53_record" "google_apps_domains-kalbas-it-cname" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "${element(var.google_apps_domains, count.index)}.kalbas.it"
  type    = "CNAME"
  ttl     = 86400

  records = [
    "ghs.googlehosted.com",
  ]

  count = length(var.google_apps_domains)
}

resource "aws_route53_record" "kalbas-it-txt" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "kalbas.it"
  type    = "TXT"
  ttl     = 86400

  records = [
    "google-site-verification=UvJ449OuIFMATBgpg0XNswXJV2l5FDGcPVDZEZ4BZ-Y",
    "protonmail-verification=829eca95699d195547e5d5eb239817f035c804eb",
    "v=spf1 include:_spf.protonmail.ch mx ~all",
  ]
}

resource "aws_route53_record" "kalbas-it-dkim" {
  for_each = {
    "protonmail._domainkey"  = "protonmail.domainkey.dlyb54kvywczmsrghlfpdun3xs7b72fnyeaz5hjx5nza2pzu3jvqa.domains.proton.ch."
    "protonmail2._domainkey" = "protonmail2.domainkey.dlyb54kvywczmsrghlfpdun3xs7b72fnyeaz5hjx5nza2pzu3jvqa.domains.proton.ch."
    "protonmail3._domainkey" = "protonmail3.domainkey.dlyb54kvywczmsrghlfpdun3xs7b72fnyeaz5hjx5nza2pzu3jvqa.domains.proton.ch."
  }

  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "${each.key}.kalbas.it"
  type    = "CNAME"
  ttl     = 86400

  records = [each.value]
}

resource "aws_route53_record" "kalbas-it-dmarc" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "_dmarc.kalbas.it"
  type    = "TXT"
  ttl     = 5

  records = [
    "v=DMARC1; p=quarantine; rua=mailto:kalbasit@pm.me"
  ]
}

resource "aws_route53_record" "kalbas-it-a" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "kalbas.it"
  type    = "A"
  ttl     = 86400

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "me-kalbas-it-a" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "me.kalbas.it"
  type    = "A"
  ttl     = 86400

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "www-kalbas-it-a" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "www.kalbas.it"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.www-kalbas-it.website_domain
    zone_id                = aws_s3_bucket.www-kalbas-it.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "_keybase-kalbas-it-txt" {
  zone_id = aws_route53_zone.kalbas-it.zone_id
  name    = "_keybase.kalbas.it"
  type    = "TXT"
  ttl     = 86400

  records = [
    "keybase-site-verification=28VcnO1S8jaoiOzfi2vLm3U8q9ViMGzoFZkedcfN9j0",
  ]
}

