resource "aws_security_group" "allow_ssh_from_anywhere" {
  name        = "allow_ssh_from_anywhere"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc_us_west_1.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name      = "allow_ssh_from_anywhere"
    Owner     = "wael"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_eternal_terminal_from_anywhere" {
  name        = "allow_eternal_terminal_from_anywhere"
  description = "Allow Eternal Terminal inbound traffic"
  vpc_id      = module.vpc_us_west_1.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 2022
    to_port     = 2022
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name      = "allow_eternal_terminal_from_anywhere"
    Owner     = "wael"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_egress_to_anywhere" {
  name        = "allow_egress_to_anywhere"
  description = "Allow all outgoing traffic"
  vpc_id      = module.vpc_us_west_1.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name      = "allow_egress_to_anywhere"
    Owner     = "wael"
    Terraform = "true"
  }
}

