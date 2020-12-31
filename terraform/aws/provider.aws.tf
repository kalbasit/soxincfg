# resource "secret_resource" "aws_access_key" {
#   lifecycle {
#     # avoid accidentally loosing the secret
#     prevent_destroy = true
#   }
# }
#
# resource "secret_resource" "aws_secret_key" {
#   lifecycle {
#     # avoid accidentally loosing the secret
#     prevent_destroy = true
#   }
# }

provider "aws" {
  alias = "us-east-1"
  # access_key = secret_resource.aws_access_key.value
  # secret_key = secret_resource.aws_secret_key.value
  region = "us-east-1"
}

provider "aws" {
  # access_key = secret_resource.aws_access_key.value
  # secret_key = secret_resource.aws_secret_key.value
  region = "us-west-1"
}

