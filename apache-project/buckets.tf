resource "aws_s3_bucket" "state_bucket" {
  bucket              = local.s3_bucket_name
  object_lock_enabled = true
  force_destroy       = true
  tags                = local.common_tags
}

resource "aws_s3_bucket_acl" "state_bucket_acl" {
  bucket = aws_s3_bucket.state_bucket.id
  acl    = "private"
}

resource "aws_iam_policy" "state_bucket_policy" {
  name        = "state_bucket_policy"
  path        = "/"
  description = "Policy for accessing state bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}"
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}/dev-state"
      }
    ]
  })
}

resource "aws_iam_policy" "state_dynamodb_policy" {
  name        = "state_dynamodb_policy"
  path        = "/"
  description = "Policy for accessing dynamodb table"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/state_table"
      }
    ]
    }
  )
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "config_bucket" {
  bucket              = "apache-config-${random_integer.rand.result}"
  object_lock_enabled = true
  force_destroy       = true
  tags                = local.common_tags
}

resource "aws_s3_bucket_object" "website_index" {
  bucket = aws_s3_bucket.config_bucket
  key    = "index.html"
  source = "./index.html"
}

resource "aws_s3_bucket_object" "ansible_playbook" {
  bucket = aws_s3_bucket.config_bucket
  key = "playbook.yaml"
  source = "./ansible/playbook.yaml"
}