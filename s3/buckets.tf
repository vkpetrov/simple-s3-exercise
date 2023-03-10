resource "aws_s3_bucket" "dev_bucket" {
  bucket = local.s3_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_acl" "dev_bucket_acl" {
  bucket = aws_s3_bucket.dev_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "dev_bucket_policy" {
  bucket = aws_s3_bucket.dev_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Condition = {
          IpAddress : {
            "aws:SourceIp" : ["${local.access_ip}"]
          }
        }
        Resource = [
          "${aws_s3_bucket.dev_bucket.arn}",
          "${aws_s3_bucket.dev_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.dev_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object" "welldone" {
  bucket       = aws_s3_bucket.dev_bucket.id
  key          = "welldone.png"
  source       = "./welldone.png"
  acl          = "authenticated-read"
  content_type = "image/png"
}