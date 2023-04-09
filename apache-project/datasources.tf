data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "dev-state-bucket-88794"
    key    = "dev-terraform.tfstate"
    region = "us-east-1"
  }
}