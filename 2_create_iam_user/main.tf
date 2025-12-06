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

resource "aws_iam_user" "user" {
  name          = "created-by-terraform" # IAM User 名稱
  path          = "/deploy/"             # 分類前綴，一般預設 "/"，影響在顯示資訊時會變成 arn:aws:iam::123456789012:user/path/username
  force_destroy = true                   # true 時，會一併刪除 access keys 等資源

  tags = {
    Project = "demo-terraform"
    Owner   = "infra-team"
  }
}

output "name" {
  value = aws_iam_user.user.name
}

output "arn" {
  value = aws_iam_user.user.arn
}

output "id" {
  value = aws_iam_user.user.id
}

output "unique_id" {
  value = aws_iam_user.user.unique_id
}

output "tags" {
  value = aws_iam_user.user.tags_all
}

resource "aws_iam_user_login_profile" "user" {
  user                    = aws_iam_user.user.name
  password_reset_required = true

  # 使用 keybase 管理的 PGP 加密
  # pgp_key = "keybase:your-keybase-id"

  # 使用本機檔案加密
  pgp_key = filebase64("${path.module}/pgp-public-key.gpg")
}

output "console_user_encrypted_password" {
  value     = aws_iam_user_login_profile.user.encrypted_password
  sensitive = true
}

output "console_user_pgp_fingerprint" {
  value = aws_iam_user_login_profile.user.key_fingerprint
}

# 建立使用者群組
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group
resource "aws_iam_group" "admins" {
  name = "terraform-lab"
  path = "/lab/"
}

# 將使用者加入群組
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership
resource "aws_iam_group_membership" "admins_membership" {
  name  = "terraform-lab-membership"
  group = aws_iam_group.admins.name
  users = [
    aws_iam_user.user.name,
  ]
}

# 加入使用權限
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment
resource "aws_iam_group_policy_attachment" "admins_policy" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_alias
resource "aws_iam_account_alias" "this" {
  account_alias = "terraform-lab-user"
}

# gpg --gen-key
# gpg --export you@example.com > pgp-public-key.gpg
# terraform output -raw console_user_encrypted_password | base64 --decode | gpg --decrypt
