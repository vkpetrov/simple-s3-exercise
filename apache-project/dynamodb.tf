resource "aws_dynamodb_table" "state_table" {
  name           = "state_table"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.common_tags
}