terraform {
  backend "s3" {
    bucket = "nasreddine-infra"
    key    = "terraform/unifi.tfstate"
    region = "us-west-1"
  }
}
