resource "aws_instance" "x86-64-linux-0" {
  ami           = "ami-04befdb203b4b17f6"
  instance_type = "t2.xlarge"

  disable_api_termination = true
  key_name                = "yubikey_5c_09501258"
  vpc_security_group_ids = [
    aws_security_group.allow_egress_to_anywhere.id,
    aws_security_group.allow_eternal_terminal_from_anywhere.id,
    aws_security_group.allow_ssh_from_anywhere.id,
  ]
  subnet_id                   = module.vpc_us_west_1.public_subnets[0]
  associate_public_ip_address = true

  root_block_device { volume_size = 500 }

  tags = {
    Name      = "x64-64-linux-0"
    Owner     = "wael"
    Terraform = "true"
  }
}

resource "aws_route53_record" "x86-64-linux-0_yl_ktdev_io" {
  zone_id = aws_route53_zone.yl_ktdev_io.zone_id
  name    = "x86-64-linux-0"
  type    = "A"
  ttl     = 300
  records = [aws_instance.x86-64-linux-0.public_ip]
}
