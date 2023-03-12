##################################################################################
# CONFIGURATION
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "deep-dive"
  region  = var.aws_region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# DATA
##################################################################################

data "consul_keys" "apache" {
  key {
    name = "common_tags"
    path = "apache/configuration/common_tags"
  }
  key {
    name = "net_info"
    path = "apache/configuration/net_info"
  }
}

data "terraform_remote_state" "s3_remote_state" {
  backend = "s3"
  config = {
    bucket  = "dev-state-bucket-88794"
    key     = "dev-terraform.tfstate"
    region  = "us-east-1"
    profile = "deep-dive"
  }
}

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# Generate random ID for unique s3 bucket naming

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

##################################################################################
# LOCALS
##################################################################################

locals {
  s3_bucket_name = "dev-state-bucket-${random_integer.rand.result}"
  common_tags    = jsondecode(data.consul_keys.apache.var.common_tags)
  #cidr_block     = jsonencode(data.consul_keys.apache.var.net_info)["cidr_block"]
  #subnet_count   = jsonencode(data.consul_keys.apache.var.net_info)["subnet_count"]
}