module "vpc_us_west_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  cidr            = "192.168.120.0/21" # 192.168.120.0 -- 192.168.127.255
  azs             = ["us-west-1a"]
  private_subnets = ["192.168.120.0/24"]
  public_subnets  = ["192.168.121.0/24"]

  tags = {
    Name      = "Wael Network"
    Owner     = "wael"
    Terraform = "true"
  }
}
