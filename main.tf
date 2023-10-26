terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_iam_user" "project_user" {
  name = "project_user"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::tf-buck-2510/*", "arn:aws:s3:::tf-buck-2510"]
  }
}

resource "aws_iam_policy" "project_policy" {
  name        = "project_policy"
  description = "Policy to allow read and write access to the tf-buck-2510 S3 bucket"
  policy      = data.aws_iam_policy_document.s3_policy.json
}


resource "aws_iam_role" "project_role" {
  name = "project_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "project_role_policy_attachment" {
  name       = "project_role_policy_attachment"
  policy_arn = aws_iam_policy.project_policy.arn
  roles      = [aws_iam_role.project_role.name]
}


resource "aws_iam_user_policy_attachment" "project_user_policy_attachment" {
  policy_arn = aws_iam_policy.project_policy.arn
  user       = aws_iam_user.project_user.name
}


resource "aws_iam_user_policy_attachment" "delete_user_policy_attachment" {
  policy_arn = aws_iam_policy.project_policy.arn
  user       = aws_iam_user.project_user.name
  count      = var.delete_user ? 0 : 1
}


resource "aws_iam_user" "delete_user" {
  name  = "project_user"
  count = var.delete_user ? 0 : 1
}

variable "delete_user" {
  type        = bool
  default     = true
}








