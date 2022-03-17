provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "soxin_account_1"
  version = "3.56.0"
}

provider "aws" {
  region  = "us-west-1"
  profile = "soxin_account_1"
  version = "3.56.0"
}
