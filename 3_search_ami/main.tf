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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

output "ami_info" {
  value = jsonencode(data.aws_ami.al2023)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"]
  }

  # https://documentation.ubuntu.com/aws/aws-how-to/instances/find-ubuntu-images/#ownership-verification
  owners = ["099720109477"]
}

output "ubuntu_info" {
  value = jsonencode(data.aws_ami.ubuntu)
}