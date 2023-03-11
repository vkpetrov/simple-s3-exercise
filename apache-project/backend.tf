terraform {
  backend "s3" {
    bucket         = "dev-state-bucket-88794"
    key            = "dev-terraform.tfstate"
    dynamodb_table = "state_table"
    region         = "us-east-1"
    profile        = "deep-dive"
  }
}