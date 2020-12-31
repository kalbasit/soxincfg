terraform {
  backend "s3" {
    bucket  = "nasreddine-infra"
    key     = "terraform/aws/account_1.tfstate"
    region  = "us-west-1"
    profile = "soxin_account_1"
  }
}

