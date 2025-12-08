# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25.0"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration
# 使用特定 aws credential
provider "aws" {
  alias  = "application"
  # profile = "test"
  region = "ap-southeast-1"
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
  # shared_config_files      = ["/Users/tf_user/.aws/conf"]
  # shared_credentials_files = ["/Users/tf_user/.aws/creds"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_user_id" {
  value = data.aws_caller_identity.current.user_id
}