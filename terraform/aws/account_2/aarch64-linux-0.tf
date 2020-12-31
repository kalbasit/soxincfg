resource "aws_instance" "aarch64-linux-0" {
  ami           = "ami-02d147d2cb992f878"
  instance_type = "c6g.xlarge"

  disable_api_termination = true
  key_name                = "yubikey_5c_09501258"
  vpc_security_group_ids = [
    aws_security_group.allow_ssh_from_anywhere.id,
    aws_security_group.allow_egress_to_anywhere.id
  ]
  subnet_id                   = module.vpc_us_west_1.public_subnets[0]
  associate_public_ip_address = true

  root_block_device { volume_size = 500 }

  tags = {
    Name      = "aarch64-linux-0"
    Owner     = "wael"
    Terraform = "true"
  }
}

resource "aws_route53_record" "aarch64-linux-0_yl_ktdev_io" {
  zone_id = aws_route53_zone.yl_ktdev_io.zone_id
  name    = "aarch64-linux-0"
  type    = "A"
  ttl     = 300
  records = [aws_instance.aarch64-linux-0.public_ip]
}
