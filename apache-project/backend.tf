terraform {
  backend "s3" {
    bucket  = "dev-state-bucket-99535"
    key     = "dev-state"
    region  = "us-east-1"
    profile = "deep-dive"
  }
}